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
  "service/master-slave-cluster/airflow_master.yml"
  #"service/common/postgres.yml" Containerized Postgresql service definition if Postgresql not managed service comment out line
  #"service/common/redis.yml" Containerized Redis service definition
  # ------------------------------
  # ----------- Ingress ----------
  "ingress/master-slave-cluster/airflow_ui.yml"
  # ------------------------------
  # -------- Deployments ---------
  "deployment/master-slave-cluster/airflow_master.yml"
  "deployment/master-slave-cluster/airflow_worker.yml"
  #"deployment/common/postgres.yml" Containerized Postgresql deployment if Postgresql not managed service comment out line
  #"deployment/common/redis.yml" Containerized Redis deployment if Redis not managed service comment out line
  # ------------------------------
)

for K8S_FILE_PATH in ${K8S_FILE_PATHS[@]}; do
  kubectl $1 -f $K8S_FILE_PATH
done
