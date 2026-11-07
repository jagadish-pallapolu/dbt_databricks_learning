-- Ad-hoc analysis: Top 5 VIP Customers by Lifetime Revenue
select
    customer_id,
    full_name,
    country_code,
    lifetime_revenue_usd,
    lifetime_profit_usd,
    total_successful_orders
from "dev"."gold"."dim_customers"
where customer_tier = 'VIP'
order by lifetime_revenue_usd desc
limit 5;
