#!/usr/bin/env bash

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
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_PASSWORD="password"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_LDAP="ldap"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_GOOGLE="google"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_GITHUB_ENTERPRISE="github_enterprise"

# $1: message
function __log__() {
  echo "[$(date '+%d/%m/%Y %H:%M:%S')] -> $1"
}

# $1: Service name
# $2: Service type
# $3: Service hostname
# $4: Service port
function health_checker() {
  __log__ "Airflow $1 healtcheck started ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")..."
  nc -z $3 $4
  result=$?
  counter=0

  until [[ $result -eq 0 ]]; do
    (( counter = counter + 1 ))

    if [[ ${AIRFLOW_MAX_RETRY_TIMES} -ne -1 && $counter -ge ${AIRFLOW_MAX_RETRY_TIMES} ]]; then
        __log__ "Airflow $1 healtcheck failed ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")..."
        __log__ "Max retry times \"${AIRFLOW_MAX_RETRY_TIMES}\" reached. Exiting now..."
        exit 1
    fi

    __log__ "Waiting $1 is ready ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\"). Retrying after ${AIRFLOW_RETRY_INTERVAL_IN_SECS} seconds... (times: $counter)."
    sleep ${AIRFLOW_RETRY_INTERVAL_IN_SECS}
    nc -z $3 $4
    result=$?
  done

  __log__ "Airflow $1 is ready ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\") ✔"
}

# $1: Service name
# $2: Service host
function __host_checker__() {
  if [[ "$2" == "NULL" ]]; then
    __log__ "Airflow $1 host is not defined. Exiting ✘..."
    exit 1
  else
    __log__ "Airflow $1 host is $2. OK ✔"
  fi
}

function check_hosts_defined() {
    __host_checker__ "${AIRFLOW_COMPONENT_DATABASE}" "${AIRFLOW_DATABASE_HOST}"

    if [[ "${CORE_EXECUTOR}" == "${AIRFLOW_EXECUTOR_CELERY}" ]]; then
        __host_checker__ "${AIRFLOW_COMPONENT_BROKER}" "${AIRFLOW_BROKER_HOST}"
        __host_checker__ "${AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND}" "${AIRFLOW_BROKER_RESULT_BACKEND_HOST}"
    fi
}

function apply_default_ports_ifnotdef() {
  if [[ "${AIRFLOW_DATABASE_PORT}" == "NULL" ]]; then
      __log__ "Airflow database port is not defined. Default port \"${__SERVICE_PORTS__[${AIRFLOW_DATABASE_TYPE}]}\" will be used!"
      export AIRFLOW_DATABASE_PORT=${__SERVICE_PORTS__[${AIRFLOW_DATABASE_TYPE}]}
  fi

  if [[ "${AIRFLOW_BROKER_PORT}" == "NULL" ]]; then
      __log__ "Airflow broker port is not defined. Default port \"${__SERVICE_PORTS__[${AIRFLOW_BROKER_TYPE}]}\" will be used!"
      export AIRFLOW_BROKER_PORT=${__SERVICE_PORTS__[${AIRFLOW_BROKER_TYPE}]}
  fi

  if [[ "${AIRFLOW_BROKER_RESULT_BACKEND_PORT}" == "NULL" ]]; then
      __log__ "Airflow broker result backend port is not defined. Default port \"${__SERVICE_PORTS__[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE}]}\" will be used!"
      export AIRFLOW_BROKER_RESULT_BACKEND_PORT=${__SERVICE_PORTS__[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE}]}
  fi
}

function __delete_pid_file__() {
    # if pid file is already exists, firstly delete it then run airflow service
    if [[ -f "${AIRFLOW_HOME}/airflow-$daemon.pid" ]]; then
        rm "${AIRFLOW_HOME}/airflow-$daemon.pid"
    fi
}
# $1: daemon
function __start_daemon__() {
    __delete_pid_file__ $daemon

    __log__ "Starting Airflow daemon \"$1\"..."
    airflow $1
    exec_result=$?
    counter=0

    until [[ $exec_result -eq 0 ]]; do
        (( counter = counter + 1 ))

        if [[ ${AIRFLOW_MAX_RETRY_TIMES} -ne -1 && $counter -ge ${AIRFLOW_MAX_RETRY_TIMES} ]]; then
          __log__ "Airflow daemon \"$daemon\" start failed!"
          __log__ "Max retry times \"${AIRFLOW_MAX_RETRY_TIMES}\" reached. Exiting now..."
          exit 1
        fi

        __delete_pid_file__ $daemon

        __log__ "Airflow daemon \"$daemon\" couldn't be started. Retrying after ${AIRFLOW_RETRY_INTERVAL_IN_SECS} seconds... (times: $counter)."
        sleep ${AIRFLOW_RETRY_INTERVAL_IN_SECS}

        airflow $1
        exec_result=$?
    done
}

function password_auth_create_initial_users() {
    for row in ${AIRFLOW_INITIAL_USERS[@]}; do
        IFS="|" read -r -a user_infos <<< $row

        __log__ "Creating user \"${user_infos[0]}\" on Airflow database..."

        airflow create_user --username ${user_infos[0]} \
                            --password ${user_infos[1]} \
                            --email ${user_infos[2]} \
                            --firstname ${user_infos[3]} \
                            --lastname ${user_infos[4]} \
                            --role ${user_infos[5]}
    done

}

function start_daemons() {
  for daemon in ${AIRFLOW_DAEMONS[@]}; do
      __start_daemon__ $daemon &
  done
}

# Load Airflow configuration from environment variables and save to "airflow.cfg"
./airflow_config_loader.sh

if [[ "${AIRFLOW_DAEMONS}" != "NULL" ]]; then
  # If required components hostname not defined raise error
  check_hosts_defined

  # Load default database and broker ports if not defined in environment variables
  apply_default_ports_ifnotdef

  # Check database is ready
  health_checker ${AIRFLOW_COMPONENT_DATABASE} ${AIRFLOW_DATABASE_TYPE} ${AIRFLOW_DATABASE_HOST} ${AIRFLOW_DATABASE_PORT}

  if [[ "${CORE_EXECUTOR}" == "${AIRFLOW_EXECUTOR_CELERY}" ]]; then
    # Check broker is ready
    health_checker ${AIRFLOW_COMPONENT_BROKER} ${AIRFLOW_BROKER_TYPE} ${AIRFLOW_BROKER_HOST} ${AIRFLOW_BROKER_PORT}

    # Check result backend is ready
    health_checker ${AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND} ${AIRFLOW_BROKER_RESULT_BACKEND_TYPE} ${AIRFLOW_BROKER_RESULT_BACKEND_HOST} ${AIRFLOW_BROKER_RESULT_BACKEND_PORT}
  fi

  __log__ "Initializing Airflow database..."

  airflow initdb

  if [[ "${WEBSERVER_AUTHENTICATE}" == "True" && \
        "${AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE}" == "${AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_PASSWORD}" && \
        "${AIRFLOW_INITIAL_USERS}" != "NULL" ]]; then
      password_auth_create_initial_users
  fi

  # Start daemons
  start_daemons

  tail -f /dev/null
fi