{% snapshot snapshot_customers %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['status', 'country', 'email'],
    )
}}

/*
  dbt Snapshot (SCD Type 2):
  Captures point-in-time state changes of customers.
  Generates dbt_valid_from and dbt_valid_to timestamp columns.
*/

select
    customer_id,
    first_name,
    last_name,
    email,
    country,
    status
from {{ ref('bronze_customers') }}

{% endsnapshot %}

