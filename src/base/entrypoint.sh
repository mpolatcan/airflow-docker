#!/usr/bin/env bash

# Load Airflow configurations and save it "airflow.cfg"
./config_loader.sh

if [[ "${AIRFLOW_DAEMONS}" != "NULL" ]]; then
  for daemon in ${AIRFLOW_DAEMONS[@]}; do
    if [[ "$daemon" == "scheduler" ]]; then
      echo "Initializing Airflow database..."
      airflow initdb
    fi

    airflow $daemon -D
  done

  tail -f /dev/null
fi