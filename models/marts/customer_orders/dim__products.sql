with

products as (

    select * from {{ ref('stg__raw__raw_products') }}

)

select * from products
