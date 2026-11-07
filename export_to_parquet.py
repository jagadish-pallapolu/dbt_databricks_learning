"""
export_to_parquet.py
--------------------
Demonstrates how DuckDB bridges local development to Databricks / Cloud Lakehouses.
Exports Gold marts into Parquet format, which can be directly read by Databricks,
Snowflake, or BigQuery.
"""

import os
import duckdb

def export_gold_marts():
    output_dir = "data_lake_exports"
    os.makedirs(output_dir, exist_ok=True)
    
    conn = duckdb.connect('dev.duckdb')
    
    tables = [
        ("gold.dim_customers", f"{output_dir}/dim_customers.parquet"),
        ("gold.dim_products", f"{output_dir}/dim_products.parquet"),
        ("gold.fct_orders", f"{output_dir}/fct_orders.parquet"),
        ("gold.mart_customer_daily_summary", f"{output_dir}/mart_customer_daily_summary.parquet"),
    ]
    
    print("🚀 Exporting Gold Models to Parquet (Lakehouse format)...")
    for table, filepath in tables:
        conn.sql(f"COPY (SELECT * FROM {table}) TO '{filepath}' (FORMAT PARQUET);")
        print(f"  ✓ Exported {table} -> {filepath}")
        
    print("\n✅ All Gold models exported successfully!")
    print("These Parquet files can be directly ingested into Databricks Delta Lake, Snowflake stages, or BigQuery external tables.")

if __name__ == "__main__":
    export_gold_marts()

