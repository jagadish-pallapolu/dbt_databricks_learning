

/*
  GOLD LAYER: Business Mart - Daily Sales Performance by Customer Segment
  - Aggregated for BI dashboards, reporting, executive summaries
*/

with orders as (
    select * from "dev"."gold"."fct_orders"
),

customers as (
    select * from "dev"."gold"."dim_customers"
)

select
    o.order_date,
    c.country_code,
    c.customer_tier,
    count(distinct o.order_id) as total_orders,
    count(distinct o.customer_id) as unique_purchasing_customers,
    sum(case when o.is_realized_sale then o.quantity else 0 end) as total_units_sold,
    sum(case when o.is_realized_sale then o.line_revenue_usd else 0.0 end) as daily_revenue_usd,
    sum(case when o.is_realized_sale then o.line_profit_usd else 0.0 end) as daily_profit_usd,
    round(
        sum(case when o.is_realized_sale then o.line_profit_usd else 0.0 end) /
        nullif(sum(case when o.is_realized_sale then o.line_revenue_usd else 0.0 end), 0) * 100.0,
        2
    ) as daily_profit_margin_pct
from orders o
inner join customers c
    on o.customer_id = c.customer_id
group by 1, 2, 3
