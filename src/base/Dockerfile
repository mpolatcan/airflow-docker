ARG AIRFLOW_PYTHON_VERSION=""

FROM python:${AIRFLOW_PYTHON_VERSION}

MAINTAINER Mutlu Polatcan <mutlupolatcan@gmail.com>

ENV AIRFLOW_USER_HOME="/home/airflow"
ENV AIRFLOW_HOME="${AIRFLOW_USER_HOME}/airflow" \
    AIRFLOW_CONF_DIR="${AIRFLOW_USER_HOME}/airflow" \
    AIRFLOW_VIRTUALENV="${AIRFLOW_USER_HOME}/airflow_venv"
ENV PATH=${AIRFLOW_VIRTUALENV}/bin:$PATH

ADD entrypoint.sh ${AIRFLOW_USER_HOME}/airflow_entrypoint.sh
ADD config_loader.sh ${AIRFLOW_USER_HOME}/airflow_config_loader.sh

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get -y install --no-install-recommends nano \
                                               gcc \
                                               g++ \
                                               iputils-ping \
                                               dnsutils \
                                               telnet \
                                               netcat \
                                               default-libmysqlclient-dev \
                                               libkrb5-dev \
                                               libsasl2-dev \
                                               libldap2-dev \
                                               libssl-dev \
                                               apt-transport-https \
                                               build-essential \
                                               unixodbc \
                                               unixodbc-dev \
                                               python-dev \
                                               kubectl && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup airflow && adduser --disabled-password --gecos "" --ingroup airflow airflow && \
    mkdir -p ${AIRFLOW_USER_HOME} && \
    mkdir -p ${AIRFLOW_HOME} ${AIRFLOW_VIRTUALENV} && \
    pip3 install virtualenv psycopg2-binary && \
    virtualenv -p python3 ${AIRFLOW_VIRTUALENV} && \
    ${AIRFLOW_VIRTUALENV}/bin/pip3 install statsd && \
    chmod +x ${AIRFLOW_USER_HOME}/airflow_entrypoint.sh ${AIRFLOW_USER_HOME}/airflow_config_loader.sh