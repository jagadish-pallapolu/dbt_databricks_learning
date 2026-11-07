

/*
  BRONZE LAYER: Raw Orders
  - Direct 1:1 view of raw transaction stream
*/

select
    cast(order_id as integer) as order_id,
    cast(customer_id as integer) as customer_id,
    cast(product_id as varchar) as product_id,
    cast(order_date as date) as order_date,
    cast(quantity as integer) as quantity,
    lower(trim(cast(status as varchar))) as status,
    current_timestamp as ingested_at
from "dev"."raw_seed"."raw_orders"