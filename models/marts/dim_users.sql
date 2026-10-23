select
    user_pseudo_id,
    min(event_date)                              as first_seen_date,
    date_trunc(min(event_date), week(monday))    as cohort_week,
    max(if(event_name = 'first_visit', 1, 0))    as is_new_user,
    any_value(first_medium)                      as first_medium,
    any_value(device_category)                   as device_category,
    countif(event_name = 'purchase')             as purchases
from {{ ref('stg_ga4__events') }}
group by user_pseudo_id