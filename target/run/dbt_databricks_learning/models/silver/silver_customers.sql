
    

    create  table
      "dev"."silver"."silver_customers__dbt_tmp"
  
    
    as (
      

/*
  SILVER LAYER: Cleaned & Enriched Customers
  - Conformed full names
  - Normalized email & country
  - Business classification flags
*/

with source as (
    select * from "dev"."bronze"."bronze_customers"
)

select
    customer_id,
    first_name,
    last_name,
    trim(first_name) || ' ' || trim(last_name) as full_name,
    lower(trim(email)) as email,
    upper(trim(country)) as country_code,
    signup_date,
    status as account_status,
    case
        when status = 'active' then true
        else false
    end as is_active_account,
    ingested_at,
    current_timestamp as silver_processed_at
from source
    );
    
  