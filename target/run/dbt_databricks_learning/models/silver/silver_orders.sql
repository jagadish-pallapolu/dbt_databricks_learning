
    

    create  table
      "dev"."silver"."silver_orders__dbt_tmp"
  
    
    as (
      

/*
  SILVER LAYER: Cleaned Orders Enriched with Product Economics
  - Calculates line-item revenue, line-item cost, line-item profit
  - Standardizes status codes
*/

with orders as (
    select * from "dev"."bronze"."bronze_orders"
),

products as (
    select * from "dev"."silver"."silver_products"
)

select
    o.order_id,
    o.customer_id,
    o.product_id,
    o.order_date,
    o.quantity,
    o.status,
    p.unit_price_usd,
    p.unit_cost_usd,
    round(cast(o.quantity * p.unit_price_usd as decimal(18, 2)), 2) as line_revenue_usd,
    round(cast(o.quantity * p.unit_cost_usd as decimal(18, 2)), 2) as line_cost_usd,
    round(cast(o.quantity * p.unit_profit_usd as decimal(18, 2)), 2) as line_profit_usd,
    case
        when o.status in ('completed', 'shipped') then true
        else false
    end as is_realized_sale,
    o.ingested_at,
    current_timestamp as silver_processed_at
from orders o
left join products p
    on o.product_id = p.product_id
    );
    
  