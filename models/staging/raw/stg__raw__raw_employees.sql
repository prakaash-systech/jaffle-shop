with

source as (

    select * from {{ source('cortex_code_usecase', 'raw_employees') }}

),

renamed as (

    select

        id,
        store_id,
        first_name,
        last_name,
        role,
        hired_at,
        terminated_at

    from source

)

select * from renamed
