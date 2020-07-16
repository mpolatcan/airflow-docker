ARG AIRFLOW_PYTHON_VERSION=""

FROM mpolatcan/airflow:base-python${AIRFLOW_PYTHON_VERSION}

MAINTAINER Mutlu Polatcan <mutlupolatcan@gmail.com>

ARG CASS_DRIVER_NO_CYTHON="1"
ARG CASS_DRIVER_BUILD_CONCURRENCY="4"
ARG AIRFLOW_PYTHON_VERSION=""
ARG AIRFLOW_VERSION=""

ENV CASS_DRIVER_NO_CYTHON=${CASS_DRIVER_NO_CYTHON} \
    CASS_DRIVER_BUILD_CONCURRENCY=${CASS_DRIVER_BUILD_CONCURRENCY}

RUN ${AIRFLOW_VIRTUALENV}/bin/pip3 install apache-airflow[all]==${AIRFLOW_VERSION} --constraint https://raw.githubusercontent.com/apache/airflow/${AIRFLOW_VERSION}/requirements/requirements-python${AIRFLOW_PYTHON_VERSION}.txt && \
    ${AIRFLOW_VIRTUALENV}/bin/pip3 install --upgrade botocore && \
    chown -R airflow:airflow ${AIRFLOW_USER_HOME}

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["./airflow_entrypoint.sh"]