/*
  Singular Test: assert_order_total_is_positive
  Rule: Every realized order line item must have a quantity > 0 and positive revenue.
  In dbt, tests return failing rows. If this query returns 0 rows, the test PASSES.
*/

select
    order_id,
    customer_id,
    quantity,
    line_revenue_usd
from "dev"."silver"."silver_orders"
where is_realized_sale = true
  and (quantity <= 0 or line_revenue_usd <= 0)