FROM mpolatcan/airflow:base

MAINTAINER Mutlu Polatcan <mutlupolatcan@gmail.com>

ARG AIRFLOW_VERSION=""

RUN pip3 install apache-airflow[all]==${AIRFLOW_VERSION}

ENTRYPOINT ["./entrypoint.sh"]