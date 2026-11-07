

/*
  GOLD LAYER: Orders Fact Table
  - Star Schema Fact Table (Grain: 1 row per order item transaction)
  - Connects to dim_customers and dim_products via foreign keys
*/

with orders as (
    select * from "dev"."silver"."silver_orders"
)

select
    order_id,
    customer_id,
    product_id,
    order_date,
    quantity,
    status,
    is_realized_sale,
    unit_price_usd,
    unit_cost_usd,
    line_revenue_usd,
    line_cost_usd,
    line_profit_usd,
    current_timestamp as gold_processed_at
from orders