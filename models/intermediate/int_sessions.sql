select
    session_key,
    user_pseudo_id,
    min(event_date)                                    as session_date,
    any_value(device_category)                         as device_category,
    any_value(country)                                 as country,
    any_value(first_medium)                            as first_medium,
    max(if(event_name = 'view_item', 1, 0))            as viewed_item,
    max(if(event_name = 'add_to_cart', 1, 0))          as added_to_cart,
    max(if(event_name = 'begin_checkout', 1, 0))       as began_checkout,
    max(if(event_name = 'add_payment_info', 1, 0))     as added_payment_info,
    max(if(event_name = 'purchase', 1, 0))             as purchased,
    sum(if(event_name = 'purchase',
           coalesce(purchase_revenue_usd, 0), 0))      as revenue_usd
from {{ ref('stg_ga4__events') }}
where session_key is not null
group by session_key, user_pseudo_id