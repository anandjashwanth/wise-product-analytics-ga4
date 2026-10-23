select
    session_date,
    device_category,
    first_medium,
    count(*)                                         as sessions,
    sum(viewed_item)                                 as step1_view_item,
    sum(viewed_item * added_to_cart)                 as step2_add_to_cart,
    sum(viewed_item * added_to_cart * began_checkout) as step3_begin_checkout,
    sum(viewed_item * added_to_cart * began_checkout
        * added_payment_info)                        as step4_payment_info,
    sum(viewed_item * added_to_cart * began_checkout
        * added_payment_info * purchased)            as step5_purchase
from {{ ref('int_sessions') }}
group by session_date, device_category, first_medium