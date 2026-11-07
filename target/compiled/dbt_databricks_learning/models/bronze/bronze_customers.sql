

/*
  BRONZE LAYER: Raw Customers
  - Mirrors Databricks raw ingestion
  - Captures ingestion timestamp (metadata)
  - Light type casting, keeping original field semantics
*/

select
    cast(customer_id as integer) as customer_id,
    cast(first_name as varchar) as first_name,
    cast(last_name as varchar) as last_name,
    cast(email as varchar) as email,
    cast(country as varchar) as country,
    cast(signup_date as date) as signup_date,
    cast(status as varchar) as status,
    current_timestamp as ingested_at
from "dev"."raw_seed"."raw_customers"