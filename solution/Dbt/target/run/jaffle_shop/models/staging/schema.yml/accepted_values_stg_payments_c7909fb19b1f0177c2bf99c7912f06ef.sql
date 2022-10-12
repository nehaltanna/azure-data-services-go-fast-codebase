select
      
      count(*) as failures,
      case when count(*) != 0
        then 'true' else 'false' end as should_warn,
      case when count(*) != 0
        then 'true' else 'false' end as should_error
    from (
      
      select *
      from "Staging"."dbo_dbt_test__audit"."accepted_values_stg_payments_c7909fb19b1f0177c2bf99c7912f06ef"
  
    ) dbt_internal_test