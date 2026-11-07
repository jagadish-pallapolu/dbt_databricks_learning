
    

    create  table
      "dev"."gold"."dim_customers__dbt_tmp"
  
    
    as (
      

/*
  GOLD LAYER: Customer Dimension with Lifetime Value (LTV)
  - Star Schema / Kimball Dimension
  - Enriched with behavioral aggregation metrics
*/

with customers as (
    select * from "dev"."silver"."silver_customers"
),

orders as (
    select * from "dev"."silver"."silver_orders"
),

customer_aggregates as (
    select
        customer_id,
        count(order_id) as total_orders_placed,
        sum(case when is_realized_sale then 1 else 0 end) as total_successful_orders,
        coalesce(sum(case when is_realized_sale then line_revenue_usd else 0 end), 0) as lifetime_revenue_usd,
        coalesce(sum(case when is_realized_sale then line_profit_usd else 0 end), 0) as lifetime_profit_usd,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date
    from orders
    group by 1
)

select
    c.customer_id,
    c.full_name,
    c.first_name,
    c.last_name,
    c.email,
    c.country_code,
    c.signup_date,
    c.account_status,
    c.is_active_account,
    coalesce(ca.total_orders_placed, 0) as total_orders_placed,
    coalesce(ca.total_successful_orders, 0) as total_successful_orders,
    coalesce(ca.lifetime_revenue_usd, 0.0) as lifetime_revenue_usd,
    coalesce(ca.lifetime_profit_usd, 0.0) as lifetime_profit_usd,
    ca.first_order_date,
    ca.most_recent_order_date,
    case
        when coalesce(ca.lifetime_revenue_usd, 0.0) >= 300 then 'VIP'
        when coalesce(ca.lifetime_revenue_usd, 0.0) > 0 then 'Regular'
        else 'Prospect'
    end as customer_tier,
    current_timestamp as gold_processed_at
from customers c
left join customer_aggregates ca
    on c.customer_id = ca.customer_id
    );
    
  