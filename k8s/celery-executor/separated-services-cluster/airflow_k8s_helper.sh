#!/bin/bash

# Written by Mutlu Polatcan
# 18.12.2019
# -------------------------

K8S_FILE_PATHS=(
  # ------ Configurations --------
  "configuration/airflow.yml"
  "configuration/airflow_secret.yml"
  "configuration/postgres.yml"
  # ------------------------------
  # --------- Services -----------
  "service/airflow_webserver.yml"
  "service/celery_flower.yml"
  "service/postgres.yml"
  "service/redis.yml"
  # ------------------------------
  # ----------- Ingress ----------
  "ingress/airflow_ui.yml"
  # ------------------------------
  # -------- Deployments ---------
  "deployment/airflow_webserver.yml"
  "deployment/airflow_scheduler.yml"
  "deployment/celery_flower.yml"
  "deployment/airflow_worker.yml"
  "deployment/postgres.yml"
  "deployment/redis.yml"
  # ------------------------------
)


for K8S_FILE_PATH in ${K8S_FILE_PATHS[@]}; do
  kubectl $1 -f $K8S_FILE_PATH
done