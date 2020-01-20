ARG PYTHON_VERSION=""

FROM mpolatcan/airflow:base-python${PYTHON_VERSION}

MAINTAINER Mutlu Polatcan <mutlupolatcan@gmail.com>

ARG AIRFLOW_VERSION=""

RUN ${AIRFLOW_VIRTUALENV}/bin/pip3 install apache-airflow[all]==${AIRFLOW_VERSION} && \
    ${AIRFLOW_VIRTUALENV}/bin/pip3 install --upgrade botocore && \
    chown -R airflow:airflow ${AIRFLOW_USER_HOME}

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["./airflow_entrypoint.sh"]