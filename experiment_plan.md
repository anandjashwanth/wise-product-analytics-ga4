# Experiment plan: raising product-view to add-to-cart

## The problem
Of 76,483 sessions that viewed a product (2 Nov 2020 to 31 Jan 2021), only 15,172 added an item to the cart: **19.8%**. Every later step converts far better, so this is the biggest leak in the funnel.

| Step | Sessions | Step conversion |
|---|---|---|
| 1 Viewed item | 76,483 | |
| 2 Added to cart | 15,172 | 19.8% |
| 3 Began checkout | 5,958 | 39.3% |
| 4 Payment info | 3,857 | 64.7% |
| 5 Purchased | 2,848 | 73.8% |

Device is not the cause: overall conversion is 0.83% on mobile, 0.78% on tablet and 0.77% on desktop.

## Hypothesis
If the product page shows the delivery cost and expected delivery date next to the Add to cart button, the add-to-cart rate will rise, because shoppers will not need to leave the page to find out the full cost and timing.

This is a hypothesis to test, not a known cause. The data shows where people drop out, not why; user research or session recordings would help choose between this and other ideas (price, stock, photos).

## Design

| Part | Choice | Why |
|---|---|---|
| Unit of randomisation | User (user_pseudo_id), 50/50 | A user always sees the same version, even across visits |
| Who is included | Sessions that view a product page | Only they can be affected by the change |
| Primary metric | Add-to-cart rate: sessions that add to cart / sessions that view a product | Measures the step being changed |
| Guardrail metrics | Overall conversion (baseline 1.35%), revenue per session (baseline $1.01), checkout-to-purchase rate (baseline 73.8%) | More carts are only good if orders and revenue do not fall |
| Minimum detectable effect | 10% relative: 19.8% to 21.8% | Smallest lift worth building; a smaller target needs a test too long to run (below) |
| Significance level | 5% (two-sided) | Standard |
| Power | 80% | Standard |

## Sample size and duration

Calculated in R:

```r
power.prop.test(p1 = 0.198, p2 = 0.218, sig.level = 0.05, power = 0.80)
```

| Target lift | Sessions needed per group | Total | Days at ~840 eligible sessions a day |
|---|---|---|---|
| 10% relative (19.8% to 21.8%) | about 6,580 | about 13,160 | about 16 days, so run **3 full weeks** |
| 5% relative (19.8% to 20.8%) | about 25,850 | about 51,700 | about 62 days, too long |

Eligible traffic: 76,483 product-viewing sessions over 91 days is about 840 a day. Running whole weeks covers weekday and weekend behaviour.

Note: the sample is counted in sessions while randomisation is by user. Sessions from the same user are not fully independent, so the real test should use a slightly larger sample or user-level analysis.

## Decision rule (set before the test starts)
- **Ship** if add-to-cart rate rises with p < 0.05 and no guardrail falls significantly.
- **Do not ship** if any guardrail falls, even if the primary metric rises.
- **Inconclusive** if neither: keep the current page and try the next hypothesis.

## Risks and checks
- **Peeking:** do not stop early when results first look significant; run the full 3 weeks.
- **Sample ratio mismatch:** check the split is close to 50/50 before reading results; a large gap means the randomisation is broken.
- **Novelty effect:** a new page element can draw clicks just for being new; 3 weeks helps it wear off.
- **Seasonality:** this baseline includes the Christmas peak; re-check the baseline in a normal month before launch.
- **Funnel coverage:** the strict funnel captures 2,848 of 4,848 purchasing sessions in the full dataset (it misses 41.3%), because some purchases skip earlier events in this dataset. The test should measure add-to-cart directly from events, not from the strict funnel.

## Wise version of the same plan
For Wise's send flow, the same method would use "transfer funded" as the primary metric, test the step with the lowest conversion (for example, recipient details to payment), and use cancellations, support contacts and fraud rate as guardrails.
