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
AIRFLOW_DAEMON_SCHEDULER="scheduler"
AIRFLOW_EXECUTOR_CELERY="CeleryExecutor"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_PASSWORD="password"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_LDAP="ldap"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_GOOGLE="google"
AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_GITHUB_ENTERPRISE="github_enterprise"

# $1: Service name
# $2: Service type
# $3: Service hostname
# $4: Service port
function health_checker() {
  echo "Airflow $1 healtcheck started ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")..."
  nc -z $3 $4
  result=$?

  until [[ $result -eq 0 ]]; do
    echo "Waiting $1 is ready ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\")..."
    sleep ${AIRFLOW_HEALTHCHECK_INTERVAL_IN_SECS}
    nc -z $3 $4
    result=$?
  done

  echo "Airflow $1 is ready ($1_type: \"$2\", $1_host: \"$3\", $1_port: \"$4\") ✔"
}

# $1: Service name
# $2: Service host
function __host_checker__() {
  if [[ "$2" == "NULL" ]]; then
    echo "Airflow $1 host is not defined. Exiting ✘..."
    exit 1
  else
    echo "Airflow $1 host is $2. OK ✔"
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
      echo "Airflow database port is not defined. Default port \"${__SERVICE_PORTS__[${AIRFLOW_DATABASE_TYPE}]}\" will be used!"
      export AIRFLOW_DATABASE_PORT=${__SERVICE_PORTS__[${AIRFLOW_DATABASE_TYPE}]}
  fi

  if [[ "${AIRFLOW_BROKER_PORT}" == "NULL" ]]; then
      echo "Airflow broker port is not defined. Default port \"${__SERVICE_PORTS__[${AIRFLOW_BROKER_TYPE}]}\" will be used!"
      export AIRFLOW_BROKER_PORT=${__SERVICE_PORTS__[${AIRFLOW_BROKER_TYPE}]}
  fi

  if [[ "${AIRFLOW_BROKER_RESULT_BACKEND_PORT}" == "NULL" ]]; then
      echo "Airflow broker result backend port is not defined. Default port \"${__SERVICE_PORTS__[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE}]}\" will be used!"
      export AIRFLOW_BROKER_RESULT_BACKEND_PORT=${__SERVICE_PORTS__[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE}]}
  fi
}

# $1: daemon
function __start_daemon__() {
    echo "Starting Airflow daemon \"$1\"..."
    airflow $1 -D
    exec_result=$?

    until [[ $exec_result -eq 0 ]]; do
        echo "Airflow daemon \"$daemon\" couldn't be started. Retrying after ${AIRFLOW_RETRY_INTERVAL_IN_SECS} seconds..."

        sleep ${AIRFLOW_RETRY_INTERVAL_IN_SECS}

        (( counter = counter + 1 ))

        if [[ ${AIRFLOW_MAX_RETRY_TIMES} -ne -1 && $counter -ge ${AIRFLOW_MAX_RETRY_TIMES} ]]; then
          echo "Max retry times \"${AIRFLOW_MAX_RETRY_TIMES}\" reached. Exiting now..."
          exit 1
        fi

        airflow $1 -D
        exec_result=$?
    done

    echo "Airflow daemon \"$daemon\" started successfully!"
}

function start_daemons() {
  for daemon in ${AIRFLOW_DAEMONS[@]}; do
      # Scheduler initializes Airflow database
      if [[ "$daemon" == "${AIRFLOW_DAEMON_SCHEDULER}" ]]; then
          echo "Initializing Airflow database..."

          airflow initdb
      fi

      __start_daemon__ $daemon &
  done
}

function password_auth_create_initial_users() {
    for row in ${AIRFLOW_INITIAL_USERS[@]}; do
        IFS="|" read -r -a user_infos <<< $row

        echo "Creating user \"${user_infos[1]}\" on Airflow database..."ü

        airflow create_user --username $user_infos[1] \
                            --password $user_infos[2] \
                            --firstname $user_infos[3] \
                            --lastname $user_infos[4] \
                            --role $user_infos[5]
    done

}

if [[ "${AIRFLOW_DAEMONS}" != "NULL" ]]; then
  # If required components hostname not defined raise error
  check_hosts_defined

  # Load default database and broker ports if not defined in environment variables
  apply_default_ports_ifnotdef

  # Load Airflow configuration from environment variables and save to "airflow.cfg"
  ./airflow_config_loader.sh

  # Check database is ready
  health_checker ${AIRFLOW_COMPONENT_DATABASE} ${AIRFLOW_DATABASE_TYPE} ${AIRFLOW_DATABASE_HOST} ${AIRFLOW_DATABASE_PORT}

  if [[ "${CORE_EXECUTOR}" == "${AIRFLOW_EXECUTOR_CELERY}" ]]; then
    # Check broker is ready
    health_checker ${AIRFLOW_COMPONENT_BROKER} ${AIRFLOW_BROKER_TYPE} ${AIRFLOW_BROKER_HOST} ${AIRFLOW_BROKER_PORT}

    # Check result backend is ready
    health_checker ${AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND} ${AIRFLOW_BROKER_RESULT_BACKEND_TYPE} ${AIRFLOW_BROKER_RESULT_BACKEND_HOST} ${AIRFLOW_BROKER_RESULT_BACKEND_PORT}
  fi

  # Start daemons
  start_daemons

  # If Webserver authentication enabled and authentication type
  # is username-password style, create initial users if defined
  if [[ "${WEBSERVER_AUTHENTICATE}" == "True" && \
        "${AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE}" == "${AIRFLOW_WEBSERVER_AUTH_BACKEND_TYPE_PASSWORD}" && \
        "${AIRFLOW_INITIAL_USERS}" != "NULL" ]]; then
      password_auth_create_initial_users
  fi

  tail -f /dev/null
fi