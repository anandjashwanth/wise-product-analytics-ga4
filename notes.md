# Exploration notes

Working notes from looking at the GA4 sample before building anything in dbt, and from the analysis queries after. Numbers marked ___ are ones I still need to copy in from my query results.

## Q1 - what one row is

- One row = one event (a page view, an add to cart, a purchase etc.), not one visit.
- event_date is text like 20201101, so it needs parse_date before I can use it as a date.
- event_timestamp is microseconds since 1970. First row I looked at was 1604192082302672, which is 1 Nov 2020 00:54 UTC.
- device and geo are nested, so it's device.category and geo.country.

## Q2 - which events exist

- Funnel events I need: view_item, add_to_cart, begin_checkout, add_payment_info, purchase.
- Users per event: view_item ___, add_to_cart ___, begin_checkout ___, add_payment_info ___, purchase ___.
- Most rows are page_view, user_engagement and session_start. The funnel events are a small share.

## Q3 - getting the session id

- event_params is a list of key/value pairs inside each row. Each event has its own list.
- The value sits in string_value or int_value depending on the type. ga_session_id is in int_value (e.g. 4863244888).
- Pulled it out with a subquery on unnest(event_params) where key = 'ga_session_id'.
- Session ids repeat across users, so a session has to be user_pseudo_id + ga_session_id together.

## Q4 - daily trend

- Busiest day: ___ with ___ users.
- Traffic builds through late Nov and early Dec, peaks before Christmas, then drops off over the holidays and recovers a bit in January.
- Worth remembering when reading anything else: the whole window includes the Christmas peak.

## Q5 - data quality

- Device split (users): desktop ___, mobile ___, tablet ___.
- Rows with missing country: ___.
- Saw masked values like ___ (Google scrambled parts of this sample on purpose).
- traffic_source is the channel that first brought the user, not the channel for each visit. Need to say that if I split by channel.

## After building the models (2 Nov 2020 to 31 Jan 2021)

### Funnel (5a)
- Viewed item 76,483 > added to cart 15,172 > began checkout 5,958 > payment info 3,857 > purchased 2,848.
- View to cart is only 19.8%. The later steps are 39.3%, 64.7% and 73.8%.
- So people mostly leave on the product page, not at checkout. That's the step to test.

### Device (5b)
- Full-funnel conversion: mobile 0.83%, tablet 0.78%, desktop 0.77%.
- Basically the same on every device. Device isn't the problem.

### Totals
- 357,504 sessions, 4,835 orders, 1.35% conversion, $361,392 revenue.
- Conversion on the dashboard is total orders / total sessions. Averaging the daily rates would give quiet days too much weight.

### Retention (5e)
- Week 1 return rate for the November cohorts: 4.25%, 5.67%, 5.25%, 4.6%.
- By week 4 it's under 2% for all of them.
- Most new users never come back. Normal enough for a merch shop, but for something like Wise this number would matter a lot.
- Later cohorts have blank cells on the right because the data ends on 31 Jan. Those weeks just haven't happened yet in the data.

### Sanity check (5g)
- Sessions match in fct_daily_kpis and fct_funnel: 360,129 each (full dataset, from 1 Nov).
- All purchasing sessions: 4,848. Purchases that went through every funnel step: 2,848.
- So the strict funnel misses 41.3% of purchases. Some purchases have no earlier funnel events in this sample.
- The dashboard numbers are slightly lower than these because its date range starts on 2 Nov.

## Things to remember for the write-up
- Biggest leak: product view to add to cart (19.8%).
- Device makes no real difference.
- Retention is very low after week 1.
- Funnel only covers about 59% of purchases, so say that clearly.
