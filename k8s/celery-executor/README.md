# Airflow Distributed Architecture with Celery and Kubernetes Executor using Kubernetes

Documentation coming soon...

## TODO

- Airflow Scheduler and Webserver healthchecks
- Persistent Volume decision (NFS etc.), Persistent Volumes and Claims definitions for storage
- AWS and Google Cloud specific Kubernetes definitions will be implemented.
- Remote Logging on Google Cloud and AWS
- Helm operator implementation.

## Architecture

### Master - Worker Cluster

#### Generic

![](../../img/Airflow%20Distributed%20Architecture%20with%20Celery%20Executor%20on%20Kubernetes%20(Generic%20-%20Master%20Worker%20Pods).png)

#### AWS 

##### Components

- **AWS Elastic Kubernetes Service**
- **AWS RDS** (managed **PostgreSQL** and **MySQL**)
- **AWS ElastiCache** (managed **Redis**)
- **AWS Elastic File System**

![](../../img/Airflow%20Distributed%20Architecture%20with%20Celery%20Executor%20on%20Kubernetes%20(AWS%20-%20Master%20Worker%20Pods).png)

#### Google Cloud

Coming soon...

### Separated Services Cluster

#### Generic

![](../../img/Airflow%20Distributed%20Architecture%20with%20Celery%20Executor%20on%20Kubernetes%20(Generic%20-%20Separated%20Services%20Pods).png)

## Master 

