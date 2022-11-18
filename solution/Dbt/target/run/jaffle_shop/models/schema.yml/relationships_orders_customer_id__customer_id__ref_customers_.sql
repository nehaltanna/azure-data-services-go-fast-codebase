select
      
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
      select *
      from "Staging"."dbo_dbt_test__audit"."relationships_orders_customer_id__customer_id__ref_customers_"
  
    ) dbt_internal_test