



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
from "dev"."bronze"."bronze_customers"
