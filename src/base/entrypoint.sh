#!/usr/bin/env bash

AIRFLOW_COMPONENT_DATABASE="database"
AIRFLOW_COMPONENT_BROKER="broker"
AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND="broker_result_backend"
AIRFLOW_DAEMON_SCHEDULER="scheduler"
AIRFLOW_EXECUTOR_CELERY="CeleryExecutor"

declare -A SERVICE_PORTS

SERVICE_PORTS[postgresql]="5432"
SERVICE_PORTS[mysql]="3306"
SERVICE_PORTS[redis]="6379"
SERVICE_PORTS[rabbitmq]="5672"

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

function check_hosts_defined() {
    __host_checker__ "${AIRFLOW_COMPONENT_DATABASE}" "${AIRFLOW_DATABASE_HOST}"

    if [[ "${CORE_EXECUTOR}" == "${AIRFLOW_EXECUTOR_CELERY}" ]]; then
        __host_checker__ "${AIRFLOW_COMPONENT_BROKER}" "${AIRFLOW_BROKER_HOST}"
        __host_checker__ "${AIRFLOW_COMPONENT_BROKER_RESULT_BACKEND}" "${AIRFLOW_BROKER_RESULT_BACKEND_HOST}"
    fi
}

function apply_default_ports_ifnotdef() {
  if [[ "${AIRFLOW_DATABASE_PORT}" == "NULL" ]]; then
      echo "Airflow database port is not defined. Default port \"${SERVICE_PORTS[${AIRFLOW_DATABASE_TYPE}]}\" will be used!"
      export AIRFLOW_DATABASE_PORT=${SERVICE_PORTS[${AIRFLOW_DATABASE_TYPE}]}
  fi

  if [[ "${AIRFLOW_BROKER_PORT}" == "NULL" ]]; then
      echo "Airflow broker port is not defined. Default port \"${SERVICE_PORTS[${AIRFLOW_BROKER_TYPE}]}\" will be used!"
      export AIRFLOW_BROKER_PORT=${SERVICE_PORTS[${AIRFLOW_BROKER_TYPE}]}
  fi

  if [[ "${AIRFLOW_BROKER_RESULT_BACKEND_PORT}" == "NULL" ]]; then
      echo "Airflow broker result backend port is not defined. Default port \"${SERVICE_PORTS[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE}]}\" will be used!"
      export AIRFLOW_BROKER_RESULT_BACKEND_PORT=${SERVICE_PORTS[${AIRFLOW_BROKER_RESULT_BACKEND_TYPE}]}
  fi
}

function start_daemons() {
  for DAEMON in ${AIRFLOW_DAEMONS[@]}; do
    # Scheduler initializes Airflow database
    if [[ "$DAEMON" == "${AIRFLOW_DAEMON_SCHEDULER}" ]]; then
        echo "Initializing Airflow database..."

        airflow initdb
    fi

    echo "Starting Airflow daemon \"$DAEMON\"..."
    airflow $DAEMON -D &> "airflow_$DAEMON.log"
    exec_result=$?

    counter=0

    until [[ $exec_result -eq 1 ]]; do
      echo "Airflow daemon \"$DAEMON\" couldn't be started. Retrying after ${AIRFLOW_RETRY_INTERVAL_IN_SECS} seconds..."

      sleep ${AIRFLOW_RETRY_INTERVAL_IN_SECS}

      (( counter = counter + 1 ))

      if [[ ${AIRFLOW_MAX_RETRY_TIMES} -ne -1 && $counter -ge ${AIRFLOW_MAX_RETRY_TIMES} ]]; then
          echo "Max retry times \"${AIRFLOW_MAX_RETRY_TIMES}\" reached. Exiting now..."
          exit 1
      fi

      airflow $DAEMON -D &> "airflow_$DAEMON.log"
      exec_result=$?
    done
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

  tail -f /dev/null
fi