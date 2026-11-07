#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=========================================================="
echo "  dbt + Databricks Medallion Learning Pipeline"
echo "  Target: DuckDB (Offline & Local Zero-Cost DWH)"
echo "=========================================================="

# Activate virtual environment
source .venv/bin/activate

echo "1. Checking Connection..."
dbt debug --profiles-dir .

echo "2. Loading Seed Data (Raw CSV Ingestion)..."
dbt seed --profiles-dir .

echo "3. Executing Medallion Pipeline (Bronze -> Silver -> Gold)..."
dbt run --profiles-dir .

echo "4. Running Data Quality Tests..."
dbt test --profiles-dir .

echo "5. Executing SCD Type 2 Snapshots..."
dbt snapshot --profiles-dir .

echo "6. Generating dbt Documentation & Data Catalog..."
dbt docs generate --profiles-dir .

echo "7. Exporting to Parquet for Lakehouse Interoperability..."
python3 export_to_parquet.py

echo "=========================================================="
echo "✅ Pipeline successfully completed!"
echo "To explore documentation: dbt docs serve --profiles-dir ."
echo "=========================================================="

