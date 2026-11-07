

/*
  SILVER LAYER: Cleaned & Enriched Products
  - Converts cents to dollars using custom macro
  - Computes unit margin and unit margin percentage
*/

with source as (
    select * from "dev"."bronze"."bronze_products"
)

select
    product_id,
    product_name,
    category,
    unit_price_cents,
    cost_cents,
    round(cast(unit_price_cents as decimal(18, 2)) / 100.0, 2) as unit_price_usd,
    round(cast(cost_cents as decimal(18, 2)) / 100.0, 2) as unit_cost_usd,
    round(cast(unit_price_cents - cost_cents as decimal(18, 2)) / 100.0, 2) as unit_profit_usd,
    round(
        cast((unit_price_cents - cost_cents) as double) / nullif(unit_price_cents, 0) * 100.0,
        2
    ) as profit_margin_pct,
    ingested_at,
    current_timestamp as silver_processed_at
from source
