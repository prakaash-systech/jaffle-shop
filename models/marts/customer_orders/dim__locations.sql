with

locations as (

    select * from {{ ref('stg__raw__raw_stores') }}

)

select * from locations
