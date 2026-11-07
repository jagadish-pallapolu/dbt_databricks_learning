# End-to-End dbt & Databricks Learning Pipeline

A complete, production-grade dbt pipeline implementing the **Databricks Medallion Architecture (Bronze → Silver → Gold)**.

It runs **100% offline and locally** using **DuckDB** (a zero-cost, high-performance in-process columnar data warehouse) and is engineered to be **seamlessly migrated to Databricks, Snowflake, Google BigQuery**, or any cloud data lakehouse without changing your business SQL.

---

## 🏗️ Architecture: Databricks Medallion & dbt

```
[Raw CSVs / Seeds]
       │
       ▼
 🥉 BRONZE (Raw Staging)
    ├── bronze_customers (View)
    ├── bronze_products  (View)
    └── bronze_orders    (View)
       │
       ▼
 🥈 SILVER (Cleaned & Conformed)
    ├── silver_customers (Table + Tests)
    ├── silver_products  (Table + Profit Macro)
    └── silver_orders    (Table + Relationships)
       │
       ▼
 🥇 GOLD (Marts & Dimensional Models)
    ├── dim_customers    (Star Schema Dimension + LTV Metrics)
    ├── dim_products     (Catalog Performance Dimension)
    ├── fct_orders       (Granular Fact Table)
    └── mart_customer_daily_summary (Executive Business Aggregations)
```

---

## 📁 Project Directory Structure

```text
dbt_databricks_learning/
├── dbt_project.yml          # Core dbt configuration & medallion layer rules
├── profiles.yml             # Connection profiles (DuckDB, Databricks, Snowflake, BigQuery)
├── run_pipeline.sh          # One-click execution script
├── export_to_parquet.py     # Exports Gold models to Parquet (Delta/Lakehouse compatible)
│
├── seeds/                   # Raw source data (offline ingested)
│   ├── raw_customers.csv
│   ├── raw_products.csv
│   └── raw_orders.csv
│
├── models/
│   ├── bronze/              # Bronze: Direct raw ingest, metadata stamping
│   │   ├── bronze_sources.yml
│   │   ├── bronze_customers.sql
│   │   ├── bronze_products.sql
│   │   └── bronze_orders.sql
│   │
│   ├── silver/              # Silver: Normalized, validated, deduplicated, enriched
│   │   ├── silver_models.yml (Generic schema tests)
│   │   ├── silver_customers.sql
│   │   ├── silver_products.sql (Uses cents_to_dollars macro)
│   │   └── silver_orders.sql
│   │
│   └── gold/                # Gold: Star Schema & Business Intelligence marts
│       ├── gold_models.yml
│       ├── dim_customers.sql
│       ├── dim_products.sql
│       ├── fct_orders.sql
│       └── mart_customer_daily_summary.sql
│
├── macros/                  # Jinja SQL macros
│   ├── cents_to_dollars.sql
│   └── generate_schema_name.sql
│
├── snapshots/               # SCD Type 2 tracking
│   └── snapshot_customers.sql
│
├── tests/                   # Singular custom SQL assertions
│   └── assert_order_total_is_positive.sql
│
└── analyses/                # Ad-hoc analytical queries
    └── sample_query.sql
```

---

## ⚡ Quickstart: Running Offline

### 1. Automated Execution
Run the complete pipeline from root:
```bash
./run_pipeline.sh
```

### 2. Manual Step-by-Step Commands
```bash
# Activate Python environment
source .venv/bin/activate

# 1. Validate connection
dbt debug --profiles-dir .

# 2. Ingest seed datasets
dbt seed --profiles-dir .

# 3. Transform data across Bronze, Silver, and Gold layers
dbt run --profiles-dir .

# 4. Run data quality tests (21 tests: unique, not_null, relationships, singular tests)
dbt test --profiles-dir .

# 5. Capture SCD Type 2 history
dbt snapshot --profiles-dir .

# 6. Generate interactive documentation & lineage graph
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir . --port 8080
```

---

## 🧠 Core dbt Concepts Demonstrated

| dbt Concept | Implementation in this Project |
| :--- | :--- |
| **Seeds** | `seeds/raw_*.csv` load raw reference datasets without third-party loaders. |
| **Sources** | `models/bronze/bronze_sources.yml` declares upstream source tables and freshness expectations. |
| **Materializations** | Bronze as `view` (lightweight), Silver and Gold as `table` (persisted OLAP structures). |
| **Macros** | `macros/cents_to_dollars.sql` provides reusable currency calculation logic across models. |
| **Generic Tests** | `unique`, `not_null`, `accepted_values`, and `relationships` defined in YAML. |
| **Singular Tests** | `tests/assert_order_total_is_positive.sql` flags invalid rows via custom business logic. |
| **Snapshots** | `snapshots/snapshot_customers.sql` tracks historic attribute changes (SCD Type 2). |
| **Documentation & Lineage** | Self-generating interactive DAG viewer with `dbt docs serve`. |

---

## 💎 Databricks Concepts Guide

### 1. Lakehouse Architecture vs Traditional Data Warehouse
* **Data Warehouse (e.g. Traditional DW)**: Proprietary storage format, structured data only, compute and storage often tightly coupled.
* **Lakehouse (Databricks)**: Combines the flexibility/cost of object storage (S3/ADLS/GCS) with the ACID transactions, governance, and speed of a data warehouse.

### 2. Delta Lake Format
All tables created in Databricks use **Delta Lake** (open-source storage layer built on top of Parquet):
* **ACID Transactions**: Multiple writers/readers without data corruption.
* **Time Travel**: Query data at an earlier timestamp:
  ```sql
  SELECT * FROM silver.silver_customers TIMESTAMP AS OF '2024-03-01 10:00:00';
  ```
* **Compaction & Indexing**:
  * `OPTIMIZE <table_name>` merges small files into 1GB files.
  * `Z-ORDER BY (column)` clusters co-occurring data to speed up filter predicates.
  * In modern Databricks: **Liquid Clustering** (`CLUSTER BY (order_date, customer_id)`) replaces manual partitioning and Z-ordering.

### 3. Unity Catalog (Three-tier Namespace)
In Databricks Unity Catalog, objects follow a standard 3-level hierarchy:
```
<catalog>.<schema>.<table_or_view>
 e.g.:   prod_lakehouse.gold.dim_customers
```
This maps directly to our dbt structure:
* `catalog`: Defined in `profiles.yml` (`catalog: "{{ env_var('DATABRICKS_CATALOG', 'main') }}"`)
* `schema`: `bronze`, `silver`, `gold` (controlled via `+schema` and `generate_schema_name.sql`)
* `table/view`: Model file names (`dim_customers`, `fct_orders`, etc.)

---

## 🚀 Cloud Migration Blueprint

Because this pipeline is written in **strict ANSI SQL** with vendor-neutral dbt conventions, you can migrate to any cloud warehouse simply by installing the adapter and updating `profiles.yml`.

### Option A: Migrate to Databricks
1. Install Databricks adapter:
   ```bash
   pip install dbt-databricks
   ```
2. Set environment variables:
   ```bash
   export DATABRICKS_HOST="dbc-xxxxxx.cloud.databricks.com"
   export DATABRICKS_HTTP_PATH="/sql/1.0/warehouses/xxxxxx"
   export DATABRICKS_TOKEN="dapi_your_personal_access_token"
   export DATABRICKS_CATALOG="main"
   ```
3. Run with Databricks target:
   ```bash
   dbt run --target databricks --profiles-dir .
   ```
4. *(Optional Databricks optimization)*: In `dbt_project.yml`, you can configure Delta table properties:
   ```yaml
   models:
     dbt_databricks_learning:
       gold:
         +file_format: delta
         +liquid_clustered_by: ["order_date", "customer_id"]
   ```

---

### Option B: Migrate to Snowflake
1. Install Snowflake adapter:
   ```bash
   pip install dbt-snowflake
   ```
2. Set environment variables:
   ```bash
   export SNOWFLAKE_ACCOUNT="xy12345.us-east-1"
   export SNOWFLAKE_USER="my_user"
   export SNOWFLAKE_PASSWORD="my_password"
   export SNOWFLAKE_ROLE="TRANSFORMER"
   export SNOWFLAKE_DATABASE="ANALYTICS"
   export SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
   ```
3. Run with Snowflake target:
   ```bash
   dbt run --target snowflake --profiles-dir .
   ```

---

### Option C: Migrate to Google BigQuery
1. Install BigQuery adapter:
   ```bash
   pip install dbt-bigquery
   gcloud auth application-default login
   ```
2. Set environment variables:
   ```bash
   export GCP_PROJECT_ID="my-gcp-project-id"
   export BQ_DATASET="analytics"
   ```
3. Run with BigQuery target:
   ```bash
   dbt run --target bigquery --profiles-dir .
   ```

---

## 📊 Verifying Results in DuckDB

You can inspect the generated tables directly via Python or DuckDB CLI:
```bash
python3 -c "
import duckdb
conn = duckdb.connect('dev.duckdb')
print('--- VIP Customers (Gold Mart) ---')
conn.sql('SELECT customer_id, full_name, lifetime_revenue_usd, customer_tier FROM gold.dim_customers').show()

print('--- Daily Summary (Gold Mart) ---')
conn.sql('SELECT * FROM gold.mart_customer_daily_summary').show()
"
```

