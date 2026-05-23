{#-
    Authored locally in VS Code with GitHub Copilot assist.
    Aggregates per-customer order activity from the existing `orders` mart
    to expose a single, denormalised lifetime-value record per customer.
-#}

with orders as (

    select * from {{ ref('orders') }}

),

customer_orders as (

    select
        customer_id,
        min(order_date)               as first_order_date,
        max(order_date)               as most_recent_order_date,
        count(order_id)               as lifetime_orders,
        sum(amount)                   as lifetime_value,
        sum(credit_card_amount)       as lifetime_credit_card_amount,
        sum(coupon_amount)            as lifetime_coupon_amount,
        sum(bank_transfer_amount)     as lifetime_bank_transfer_amount,
        sum(gift_card_amount)         as lifetime_gift_card_amount

    from orders
    group by customer_id

),

final as (

    select
        customer_id,
        first_order_date,
        most_recent_order_date,
        lifetime_orders,
        lifetime_value,
        case
            when lifetime_orders = 0 then 0
            else lifetime_value / lifetime_orders
        end                            as avg_order_value,
        lifetime_credit_card_amount,
        lifetime_coupon_amount,
        lifetime_bank_transfer_amount,
        lifetime_gift_card_amount

    from customer_orders

)

select * from final
