# Airflow Distributed Architecture with Celery Executor using Kubernetes

**Airflow** can execute tasks in distributed machine using **Celery** which is a distributed task queue. Our **Airflow** 
**Docker** image can be deploy with **Celery Executor** on **Kubernetes** with **Kubernetes** definitions with two 
different architectures implemented at **k8/celery-executor** folder.

## TODO

- **Airflow** Scheduler and Webserver healthchecks
- **Persistent Volume** decision (NFS etc.) **for Kubernetes**, **Persistent Volumes** and **Persistent Volume Claims**
 definitions for storage
- **AWS** and **Google Cloud** specific Kubernetes definitions will be implemented.
- Remote Logging on **AWS** and **Google Cloud**.
- **Helm** operator implementation.

## Environments

### Generic

Generic architectures are cloud-agnostic that can be deploy or implemented on any cloud provider. These architectures are
**Master - Worker** and **Separated Services** cluster.

**Components**:

- **Kubernetes Cluster**
- **Docker**
- **PostgreSQL**
- **Redis**

#### Master-Worker Cluster

Master-Worker cluster architecture of distributed **Airflow** consists of single Master container and multiple Worker 
containers can scale up to n Worker containers. Master container runs three **Airflow** services which these are 
**Scheduler**, **Webserver** and **Celery Flower** which monitors **Celery** workers. Worker containers runs **Airflow**
**Worker** service. Also, this architecture includes main database, task queue broker and NFS as shared storage to share
dags in master and wo. Main database can be type of **PostgreSQL**  or **MySQL* and this database can be run as **Docker** 
container in **Kubernetes** cluster or managed service runs on cloud provider.

![](../../img/Airflow%20Distributed%20Architecture%20with%20Celery%20Executor%20on%20Kubernetes%20(Generic%20-%20Master%20Worker%20Pods).png)

#### Separated Services Cluster

Separated services cluster architecture of distributed **Airflow** consists of **Scheduler**, **Webserver** and
**Celery Flower**. This architecture has advantage of provision **Webserver** and **Celery Flower** replicas for failover
scenarios. Multiple **Scheduler** is not recommended for **Airflow** now, so that you shouldn't scale **Scheduler** 
container.  Also, this architecture includes main database, task queue broker and NFS as shared storage to share
dags in master and wo. Main database can be type of **PostgreSQL**  or **MySQL** and this database can be run as **Docker** 
container in **Kubernetes** cluster or managed service runs on cloud provider.

![](../../img/Airflow%20Distributed%20Architecture%20with%20Celery%20Executor%20on%20Kubernetes%20(Generic%20-%20Separated%20Services%20Pods).png)

---

### AWS 

**Components**:

- **AWS Elastic Kubernetes Service**
- **AWS RDS** (managed **PostgreSQL** and **MySQL**)
- **AWS ElastiCache** (managed **Redis**)
- **AWS Elastic File System**

#### Master Worker Cluster

![](../../img/Airflow%20Distributed%20Architecture%20with%20Celery%20Executor%20on%20Kubernetes%20(AWS%20-%20Master%20Worker%20Pods).png)

#### Separated Services Cluster

Coming soon...

---

### Google Cloud

Coming soon...
