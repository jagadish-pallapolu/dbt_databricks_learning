{{
    config(
        materialized='table',
        schema='gold'
    )
}}

/*
  GOLD LAYER: Product Dimension
  - Contains product pricing, cost, catalog category
  - Includes lifetime units sold and revenue metrics
*/

with products as (
    select * from {{ ref('silver_products') }}
),

orders as (
    select * from {{ ref('silver_orders') }}
),

product_sales as (
    select
        product_id,
        count(order_id) as total_order_lines,
        sum(case when is_realized_sale then quantity else 0 end) as total_units_sold,
        coalesce(sum(case when is_realized_sale then line_revenue_usd else 0 end), 0) as total_revenue_generated_usd,
        coalesce(sum(case when is_realized_sale then line_profit_usd else 0 end), 0) as total_profit_generated_usd
    from orders
    group by 1
)

select
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price_usd,
    p.unit_cost_usd,
    p.unit_profit_usd,
    p.profit_margin_pct,
    coalesce(ps.total_order_lines, 0) as total_order_lines,
    coalesce(ps.total_units_sold, 0) as total_units_sold,
    coalesce(ps.total_revenue_generated_usd, 0.0) as total_revenue_generated_usd,
    coalesce(ps.total_profit_generated_usd, 0.0) as total_profit_generated_usd,
    current_timestamp as gold_processed_at
from products p
left join product_sales ps
    on p.product_id = ps.product_id

