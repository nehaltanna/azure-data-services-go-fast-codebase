select
      
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
      select *
      from "Staging"."dbo_dbt_test__audit"."not_null_orders_amount"
  
    ) dbt_internal_test