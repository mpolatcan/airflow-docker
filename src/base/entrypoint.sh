#!/usr/bin/env bash

# Load Airflow configurations and save it "airflow.cfg"
./config_loader.sh

if [[ "${AIRFLOW_DAEMONS}" != "NULL" ]]; then
  airflow initdb

  for daemon in ${AIRFLOW_DAEMONS[@]}; do
    airflow $daemon &
  done

  tail -f /dev/null
fi