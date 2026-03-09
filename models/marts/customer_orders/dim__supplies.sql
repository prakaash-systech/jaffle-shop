with

supplies as (

    select * from {{ ref('stg__raw__raw_supplies') }}

)

select * from supplies
