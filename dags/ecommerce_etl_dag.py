from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.oracle.operators.oracle import OracleOperator
from airflow.operators.python import PythonOperator
import oracledb
import os

default_args = {
    'owner': 'haneen',
    'depends_on_past': False,
    'start_date': datetime(2026, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def check_data_quality():
    conn = oracledb.connect(
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        dsn=os.getenv("DB_DSN")
    )
    cursor = conn.cursor()
    cursor.execute("SELECT check_name, failed_rows FROM vw_dq_checks WHERE status = 'FAIL'")
    failed_checks = cursor.fetchall()
    cursor.close()
    conn.close()
    
    if failed_checks:
        raise ValueError(f"Data Quality Check Failed! Issues found: {failed_checks}")
    print("All Data Quality checks passed successfully!")

with DAG(
    'ecommerce_dw_pipeline',
    default_args=default_args,
    description='End-to-End E-Commerce Data Warehouse Pipeline',
    schedule_interval='@daily',
    catchup=False,
) as dag:

    # 1. تفريغ جدول الـ Staging قبل كل تحميل جديد
    truncate_staging = OracleOperator(
        task_id='truncate_stg_sales',
        oracle_conn_id='oracle_dw_conn',
        sql='TRUNCATE TABLE stg_sales;'
    )

    # 2. تشغيل سكريبت سحب وتنظيف الداتا ورفعها على STG_SALES (شغل أحمد وروبرتو)
    run_ingestion_and_transform = BashOperator(
        task_id='ingest_and_transform_data',
        bash_command='python /opt/airflow/scripts/etl_to_staging.py'
    )

    # 3. تحميل الـ Dimensions ثم الـ Sales
    load_dimensions = OracleOperator(
        task_id='load_dimensions',
        oracle_conn_id='oracle_dw_conn',
        sql='sql/load_dimensions.sql'
    )

    load_sales = OracleOperator(
        task_id='load_sales',
        oracle_conn_id='oracle_dw_conn',
        sql='sql/load_sales.sql'
    )

    # 4. بوابة فحص الجودة في الآخر
    dq_gate = PythonOperator(
        task_id='data_quality_check',
        python_callable=check_data_quality
    )

    truncate_staging >> run_ingestion_and_transform >> load_dimensions >> load_sales >> dq_gate
