#!/bin/bash
# Written by Mutlu Polatcan
# 18.12.2019
# -------------------------

K8S_FILE_PATHS=(
  # ------ Configurations --------
  "configuration/airflow.yml"
  "configuration/airflow_secret.yml"
  #"configuration/postgres.yml" Containerized Postgresql configuration if Postgresql not managed service comment out line
  # ------------------------------
  # --------- Services -----------
  "service/separated-services-cluster/airflow_webserver.yml"
  "service/separated-services-cluster/celery_flower.yml"
  #"service/separated-services-cluster/postgres.yml" Containerized Postgresql service definition if Postgresql not managed service comment out line
  #"service/separated-services-cluster/redis.yml" Containerized Redis service definition if Postgresql not managed service comment out line
  # ------------------------------
  # ----------- Ingress ----------
  "ingress/separated-services-cluster/airflow_ui.yml"
  # ------------------------------
  # -------- Deployments ---------
  "deployment/separated-services-cluster/airflow_webserver.yml"
  "deployment/separated-services-cluster/airflow_scheduler.yml"
  "deployment/separated-services-cluster/airflow_worker.yml"
  "deployment/separated-services-cluster/celery_flower.yml"
  #"deployment/separated-services-cluster/postgres.yml" Containerized Postgresql deployment if Postgresql not managed service comment out line
  #"deployment/separated-services-cluster/redis.yml" Containerized Redis deployment if Redis not managed service comment out line
  # ------------------------------
)

for K8S_FILE_PATH in ${K8S_FILE_PATHS[@]}; do
  kubectl $1 -f $K8S_FILE_PATH
done
