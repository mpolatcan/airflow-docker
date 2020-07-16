ARG PYTHON_VERSION=""

FROM python:${PYTHON_VERSION}

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
                                               apt-transport-https \
                                               kubectl \
                                               freetds-bin \
                                               krb5-user \
                                               ldap-utils \
                                               libffi6 \
                                               libsasl2-2 \
                                               libsasl2-modules \
                                               libssl1.1 \
                                               locales  \
                                               lsb-release \
                                               sasl2-bin \
                                               sqlite3 \
                                               unixodbc && \
    rm -rf /var/lib/apt/lists/* && \
    addgroup airflow && adduser --disabled-password --gecos "" --ingroup airflow airflow && \
    mkdir -p ${AIRFLOW_USER_HOME} && \
    mkdir -p ${AIRFLOW_HOME} ${AIRFLOW_VIRTUALENV} && \
    pip3 install virtualenv psycopg2-binary && \
    virtualenv -p python3 ${AIRFLOW_VIRTUALENV} && \
    ${AIRFLOW_VIRTUALENV}/bin/pip3 install "pymssql<3.0" statsd && \
    chmod +x ${AIRFLOW_USER_HOME}/airflow_entrypoint.sh ${AIRFLOW_USER_HOME}/airflow_config_loader.sh