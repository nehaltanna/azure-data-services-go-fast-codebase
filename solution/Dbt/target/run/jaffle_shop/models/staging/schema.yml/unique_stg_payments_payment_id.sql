select
      
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
      select *
      from "Staging"."dbo_dbt_test__audit"."unique_stg_payments_payment_id"
  
    ) dbt_internal_test