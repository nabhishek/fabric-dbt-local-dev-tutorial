with customers as (
    select
        customer_id,
        first_name,
        last_name
    from {{ ref('customers') }}
),

orders as (
    select
        customer_id,
        count(*) as order_count,
        sum(case when status = 'completed' then amount else 0 end) as completed_order_amount
    from {{ ref('orders') }}
    group by customer_id
),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        coalesce(o.order_count, 0) as order_count,
        coalesce(o.completed_order_amount, 0) as completed_order_amount
    from customers c
    left join orders o
        on c.customer_id = o.customer_id
)

select * from final
