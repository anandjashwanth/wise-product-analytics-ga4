with cohorts as (
    select user_pseudo_id, cohort_week
    from {{ ref('dim_users') }}
    where is_new_user = 1
),

cohort_size as (
    select cohort_week, count(*) as cohort_users
    from cohorts
    group by cohort_week
),

activity as (
    select distinct
        user_pseudo_id,
        date_trunc(event_date, week(monday)) as activity_week
    from {{ ref('stg_ga4__events') }}
),

joined as (
    select
        c.cohort_week,
        div(date_diff(a.activity_week, c.cohort_week, day), 7) as weeks_since_first,
        a.user_pseudo_id
    from cohorts c
    join activity a using (user_pseudo_id)
    where a.activity_week >= c.cohort_week
)

select
    j.cohort_week,
    j.weeks_since_first,
    count(distinct j.user_pseudo_id)                                 as active_users,
    any_value(s.cohort_users)                                        as cohort_users,
    safe_divide(count(distinct j.user_pseudo_id), any_value(s.cohort_users)) as retention_rate
from joined j
join cohort_size s using (cohort_week)
group by j.cohort_week, j.weeks_since_first