{{
    config(
        materialized='view',
        schema='bronze'
    )
}}

/*
  BRONZE LAYER: Raw Products
  - Standardized types
  - Preserves raw cents values for exact currency arithmetic
*/

select
    cast(product_id as varchar) as product_id,
    cast(product_name as varchar) as product_name,
    cast(category as varchar) as category,
    cast(unit_price_cents as integer) as unit_price_cents,
    cast(cost_cents as integer) as cost_cents,
    current_timestamp as ingested_at
from {{ ref('raw_products') }}

