WITH source AS (
    SELECT * FROM FINTECH_DB.RAW_DATA.RAW_TRANSACTIONS
),

staged AS (
    SELECT 
    nameOrig                                    AS customer_id,
    nameDest                                    AS recipient_id,
    step                                        AS hour_of_simulation,
    type                                        AS transaction_type,
    ROUND(amount, 2)                            AS amount,
    ROUND(oldbalanceOrg, 2)                     AS sender_balance_before,
    ROUND(newbalanceOrig, 2)                    AS sender_balance_after,
    ROUND(oldbalanceDest, 2)                    AS recipient_balance_before,
    ROUND(newbalanceDest, 2)                    AS recipient_balance_after,
    ROUND(oldbalanceOrg - newbalanceOrig, 2)    AS sender_balance_delta,
    ROUND(newbalanceDest - oldbalanceDest, 2)   AS recipient_balance_delta,
    isFraud                                     AS is_fraud,
    isFlaggedFraud                              AS is_flagged_fraud

     FROM source
)

SELECT * FROM staged
