
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select category
from "dev"."silver"."silver_products"
where category is null



  
  
      
    ) dbt_internal_test