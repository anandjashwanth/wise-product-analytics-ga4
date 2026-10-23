select
    session_date                                as date,
    count(distinct user_pseudo_id)              as users,
    count(*)                                    as sessions,
    sum(purchased)                              as purchase_sessions,
    sum(revenue_usd)                            as revenue_usd,
    safe_divide(sum(purchased), count(*))       as session_conversion_rate,
    safe_divide(sum(revenue_usd), sum(purchased)) as revenue_per_purchase_session
from {{ ref('int_sessions') }}
group by session_date