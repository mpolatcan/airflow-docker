#!/bin/bash

# Written by Mutlu Polatcan
# 17.12.2019
# ---------------------------
declare -A __SERVICE_PORTS__

__SERVICE_PORTS__[postgresql]="5432"
__SERVICE_PORTS__[mysql]="3306"
__SERVICE_PORTS__[redis]="6379"
__SERVICE_PORTS__[rabbitmq]="5672"

AIRFLOW_COMPONENT_DATABASE="database"
AIRFLOW_COMPONENT_BROKER="broker"
AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND="broker_result_backend"
AIRFLOW_DAEMON_WEBSERVER="webserver"
AIRFLOW_EXECUTOR_CELERY="CeleryExecutor"
AIRFLOW_EXECUTOR_KUBERNETES="KubernetesExecutor"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_PASSWORD="password"

# $1: message
function __log__() {
    echo "[$(date '+%d/%m/%Y %H:%M:%S')] -> $1"
}

# $1: Running command
# $2: Start message
# $3: Max retry times reached message
# $4: Retry message
# $5: Success message
function __retry_loop__() {
    __log__ "$2"
    counter=0
    $1

    until [[ $? -eq 0 ]]; do
        (( counter = counter + 1 ))

        if [[ ${AIRFLOW_MAX_RETRY_TIMES:=-1} -ne -1 && $counter -ge ${AIRFLOW_MAX_RETRY_TIMES:=-1} ]]; then
            __log__ "$3"
            __log__ "Max retry times \"${AIRFLOW_MAX_RETRY_TIMES:=-1}\" reached. Exiting ✘..."
            exit 1
        fi

        __log__ "$4. Retrying after ${AIRFLOW_RETRY_INTERVAL_IN_SECS:=2} seconds... (times: $counter)."
        sleep ${AIRFLOW_RETRY_INTERVAL_IN_SECS:=2}
        $1
    done

    __log__ "$5"
}

# $1: Component name
# $2: Component type
# $3: Component hostname
# $4: Component port
function health_checker() {
    if [[ "$3" == "" ]]; then
        __log__ "Airflow $1 host is not defined. Exiting ✘..."
        exit 1
    else
        __log__ "Airflow $1 host is $3. OK ✔"
    fi

    __retry_loop__ "nc -z $3 $4" \
                   "Airflow $1 healthcheck started ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")..." \
                   "Airflow $1 healthcheck failed ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")..." \
                   "Waiting $1 is ready ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")" \
                   "Airflow $1 is ready ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\") ✔"
}

function run_healthchecks() {
    # Check database is ready
    health_checker ${AIRFLOW_COMPONENT_DATABASE} ${AIRFLOW_DATABASE_TYPE:=postgresql} \
                   ${AIRFLOW_DATABASE_HOST:=NULL} ${AIRFLOW_DATABASE_PORT:=${__SERVICE_PORTS__[${AIRFLOW_DATABASE_TYPE:=postgresql}]}}

    if [[ "${CORE_EXECUTOR:=SequentialExecutor}" == "${AIRFLOW_EXECUTOR_CELERY}" ]]; then
        # Check broker is ready
        health_checker ${AIRFLOW_COMPONENT_BROKER} ${AIRFLOW_BROKER_TYPE:=redis} \
                       ${AIRFLOW_BROKER_HOST:=NULL} ${AIRFLOW_BROKER_PORT:=${__SERVICE_PORTS__[${AIRFLOW_BROKER_TYPE:=redis}]}}

        # Check result backend is ready
        health_checker ${AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND} ${AIRFLOW_BROKER_RESULT_BACKEND_TYPE:=postgresql} \
                       ${AIRFLOW_BROKER_RESULT_BACKEND_HOST:=NULL} ${AIRFLOW_BROKER_RESULT_BACKEND_PORT:=${__SERVICE_PORTS__[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE:=postgresql]}]}}
    fi
}

# ======================================================================================================================

function load_configs() {
    # Load Airflow configuration from environment variables and save to "airflow.cfg"
    ./airflow_config_loader.sh

    # Add configuration file as ConfigMap to Kubernetes cluster if executor is KubernetesExecutor
    if [[ "${CORE_EXECUTOR:=SequentialExecutor}" == "${AIRFLOW_EXECUTOR_KUBERNETES}" ]]; then
        __log__ "Creating Kubernetes ConfigMap \"airflow-config\" in namespace ${KUBERNETES_NAMESPACE}..."
        kubectl create configmap airflow-worker-config --from-file "${AIRFLOW_HOME}/airflow.cfg" --dry-run=true -o yaml > airflow_worker_config.yml
        kubectl apply -f airflow_worker_config.yml
        kubectl label configmap airflow-worker-config app=airflow --overwrite=True
    fi
}

# ======================================================================================================================

function password_auth_create_initial_users() {
    for row in ${AIRFLOW_INITIAL_USERS[@]}; do
        IFS="|" read -r -a user_infos <<< $row

        __log__ "Creating user \"${user_infos[0]}\" on Airflow database..."

        airflow users create --username ${user_infos[0]} \
                            --password ${user_infos[1]} \
                            --email ${user_infos[2]} \
                            --firstname ${user_infos[3]} \
                            --lastname ${user_infos[4]} \
                            --role ${user_infos[5]}
    done
}

function initialize_airflow_database() {
    __log__ "Initializing Airflow database..."

    airflow db init

    if [[ "${WEBSERVER_AUTHENTICATE:=False}" == "True" && \
          "${AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE:=NULL}" == "${AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_PASSWORD}" && \
          "${AIRFLOW_INITIAL_USERS:=NULL}" != "NULL" ]]; then
        password_auth_create_initial_users
    fi
}

# ======================================================================================================================

function main() {
    if [[ "${AIRFLOW_DAEMONS:=NULL}" != "NULL" ]]; then
        run_healthchecks

        load_configs

        initialize_airflow_database

        for daemon in ${AIRFLOW_DAEMONS[@]}; do
            if [[ "$daemon" == "worker" || "$daemon" == "flower" ]]; then
                daemon="celery $daemon"
            fi

            __retry_loop__ "airflow $daemon" \
                           "Starting Airflow daemon \"$daemon\"..." \
                           "Airflow daemon \"$daemon\" start failed!" \
                           "Airflow daemon \"$daemon\" couldn't be started." \
                           "Airflow daemon \"$daemon\" is ready." &
        done

        tail -f /dev/null
    fi
}

main