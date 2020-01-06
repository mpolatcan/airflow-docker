# Written by Mutlu Polatcan
# 12.11.2019
from airflow.models import DAG
from airflow.operators.bash_operator import BashOperator
from datetime import datetime

default_args = {
    "owner": "mpolatcan"
}

dag = DAG(
    dag_id="example_dag",
    schedule_interval="*/1 * * * *",
    start_date=datetime(year=2019, month=12, day=11, hour=11, minute=50),
    catchup=False,
    default_args=default_args
)

echo_task_1 = BashOperator(
    task_id="hello",
    bash_command="echo hello",
    dag=dag
)

echo_task_2 = BashOperator(
    task_id="distributed",
    bash_command="echo distributed",
    dag=dag
)

echo_task_3 = BashOperator(
    task_id="airflow",
    bash_command="echo Airflow",
    dag=dag
)

echo_task_4 = BashOperator(
    task_id="with",
    bash_command="echo with",
    dag=dag
)

echo_task_5 = BashOperator(
    task_id="celery",
    bash_command="echo Celery!",
    dag=dag
)

echo_task_1 >> [echo_task_2, echo_task_3, echo_task_4, echo_task_5]
