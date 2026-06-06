WITH source AS (
    SELECT * 
    FROM {{ref('stg_transactions')}}
)

, cte1 as (
    Select customer_id, count(*) as total_transactions,
    sum(amount) as total_amount_sent,
    round(avg(amount), 2) as avg_transaction_amount,
    max(amount) as max_transaction_amount, 
    count(distinct(recipient_id)) as unique_recipients,
    min(hour_of_simulation) as first_transaction_hour,
    max(hour_of_simulation) as last_transaction_hour,
    sum(case when is_fraud = 1 then 1 else 0 end) as fraud_transactions 
    from source
    group by customer_id
),

cte2 as (
    Select customer_id, 
    last_transaction_hour - first_transaction_hour as active_hours_span,
    744 - last_transaction_hour  as recency_score,
    total_transactions / nullif(last_transaction_hour - first_transaction_hour, 0) as transaction_frequency_rate,
    case 
        when avg_transaction_amount > (Select avg(amount) from {{ref('stg_transactions')}}) 
        then 1 else 0 
    end as is_high_value,
    case 
        when fraud_transactions > 0 then 1 else 0 
    end as has_fraud_history 
    from cte1

)


SELECT 
    c2.customer_id,
    -- Base features from cte1
    c1.total_transactions,
    c1.total_amount_sent,
    c1.avg_transaction_amount,
    c1.max_transaction_amount,
    c1.unique_recipients,
    c1.first_transaction_hour,
    c1.last_transaction_hour,
    c1.fraud_transactions,
    -- Churn indicator features from cte2
    c2.active_hours_span,
    c2.recency_score,
    c2.transaction_frequency_rate,
    c2.is_high_value,
    c2.has_fraud_history
FROM cte2 c2
JOIN cte1 c1 ON c2.customer_id = c1.customer_id