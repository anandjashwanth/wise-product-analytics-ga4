with source as (
    select *
    from {{ source('ga4', 'events') }}
    where _table_suffix between '20201101' and '20210131'
),

renamed as (
    select
        parse_date('%Y%m%d', event_date)    as event_date,
        timestamp_micros(event_timestamp)   as event_ts,
        event_name,
        user_pseudo_id,
        (select value.int_value from unnest(event_params)
         where key = 'ga_session_id')       as ga_session_id,
        device.category                     as device_category,
        geo.country                         as country,
        traffic_source.medium               as first_medium,
        traffic_source.source               as first_source,
        ecommerce.transaction_id            as transaction_id,
        ecommerce.purchase_revenue_in_usd   as purchase_revenue_usd
    from source
)

select
    *,
    concat(user_pseudo_id, '-', cast(ga_session_id as string)) as session_key
from renamed