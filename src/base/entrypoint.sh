#!/usr/bin/env bash

AIRFLOW_DAEMON_SCHEDULER="scheduler"
AIRFLOW_EXECUTOR_CELERY="CeleryExecutor"
AIRFLOW_DATABASE_TYPE_POSTGRESQL="postgresql"
AIRFLOW_DATABASE_TYPE_MYSQL="mysql"
AIRFLOW_BROKER_TYPE_REDIS="redis"
AIRFLOW_BROKER_TYPE_RABBITMQ="rabbitmq"

# $1: Service name
# $2: Service hostname
# $3: Service port
function __healthcheck__() {
  nc -z $2 $3
  result=$?

  until [[ $result -eq 0 ]]; do
    echo "Waiting $1 \"$2\" is ready..."
    sleep ${HEALTHCHECK_INTERVAL_IN_SECS}
    nc -z $2 $3
    result=$?
  done

  echo "$1 \"$2\" is ready ✔"
}

function database_healthcheck() {
    echo "Airflow database healtcheck started..."

    if [[ "${AIRFLOW_DATABASE_TYPE}" == "${AIRFLOW_DATABASE_TYPE_POSTGRESQL}" ]]; then
        __healthcheck__ "PostgreSQL" ${POSTGRESQL_HOST} ${POSTGRESQL_PORT}
    elif [[ "${AIRFLOW_DATABASE_TYPE}" == "${AIRFLOW_DATABASE_TYPE_MYSQL}" ]]; then
        __healthcheck__ "MySQL" ${MYSQL_HOST} ${MYSQL_PORT}
    fi

    echo "Airflow database is ready ✔"
}

function broker_healthcheck() {
    echo "Airflow broker healthcheck started..."

    if [[ "${AIRFLOW_BROKER_TYPE}" == "${AIRFLOW_BROKER_TYPE_REDIS}" ]]; then
      __healthcheck__ "Redis" ${REDIS_HOST} ${REDIS_PORT}
    elif [[ "${AIRFLOW_BROKER_TYPE}" == "${AIRFLOW_BROKER_TYPE_RABBITMQ}" ]]; then
      __healthcheck__ "RabbitMQ" ${RABBITMQ_HOST} ${RABBITMQ_PORT}
    fi

    echo "Airflow broker is ready ✔"
}

function load_default_database_and_broker_port() {
  if [[ "${AIRFLOW_DATABASE_PORT}" != "NULL" ]]; then
    if [[ "${AIRFLOW_DATABASE_TYPE}" == "${AIRFLOW_DATABASE_TYPE_POSTGRESQL}" ]]; then
        export AIRFLOW_DATABASE_PORT="${POSTGRESQL_PORT}"
    elif [[ "${AIRFLOW_DATABASE_TYPE}" == "${AIRFLOW_DATABASE_TYPE_MYSQL}" ]]; then
        export AIRFLOW_DATABASE_PORT="${MYSQL_PORT}"
    fi
  fi

  if [[ "${AIRFLOW_BROKER_PORT}" != "NULL" ]]; then
    if [[ "${AIRFLOW_BROKER_TYPE}" == "${AIRFLOW_BROKER_TYPE_REDIS}" ]]; then
        export AIRFLOW_BROKER_PORT="${REDIS_PORT}"
    elif [[ "${AIRFLOW_BROKER_TYPE}" == "${AIRFLOW_BROKER_TYPE_RABBITMQ}" ]]; then
        export AIRFLOW_BROKER_PORT="${RABBITMQ_PORT}"
    fi
  fi
}

if [[ "${AIRFLOW_DAEMONS}" != "NULL" ]]; then
  # Load default database and broker ports if not defined in environment variables
  load_default_database_port

  # Load Airflow configuration from environment variables and save to "airflow.cfg"
  ./airflow_config_loader.sh

  # Check database is ready
  database_healthcheck

  if [[ "${CORE_EXECUTOR}" == "${AIRFLOW_EXECUTOR_CELERY}" ]]; then
    # Check broker is ready
    broker_healthcheck
  fi

  # Start Daemons
  for DAEMON in ${AIRFLOW_DAEMONS[@]}; do
    if [[ "$DAEMON" == "${AIRFLOW_DAEMON_SCHEDULER}" ]]; then
        echo "Initializing Airflow database..."

        airflow initdb
    fi

    echo "Starting \"$daemon\"..."

    airflow $daemon &
  done

  tail -f /dev/null
fi