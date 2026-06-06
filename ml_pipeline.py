import snowflake.connector
import pandas as pd
import os
from sklearn.preprocessing import StandardScaler


# Connect to Snowflake and pull the data

# Connect to Snowflake
conn = snowflake.connector.connect(
    user = os.environ.get('SNOWFLAKE_USER'),
    password = os.environ.get('SNOWFLAKE_PASSWORD'),
    account='apc44937.us-east-1',
    warehouse='FINTECH_WH',
    database='FINTECH_DB',
    schema='PROD'
)

# SQL query
query = """
SELECT *
FROM FCT_CUSTOMER_FEATURES
"""

# Load data into pandas dataframe
df = pd.read_sql(query, conn)

# Verify data loaded correctly
print("Data Shape:", df.shape)
print("\nFirst 5 Rows:")
print(df.head())

# Close connection
conn.close()

df = df.drop(column = ['customer_id'])

# fill null values in transaction_frequency_rate
df['transaction_frequency_rate'] = (
    df['transaction_frequency_rate'].fillna(0)
)

# create target variable (the thing that needs to be predicted)
df['is_churned'] = (df['recency_score'] > 700).astype(int)

# Select ML features
feature_cols = [
    'total_transactions',
    'total_amount_sent',
    'avg_transaction_amount',
    'active_hours_span',
    'transaction_frequency_rate',
    'is_high_value'
]


X = df[feature_cols]
y = df['is_churned']

# 5. Scale features
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Convert back to DataFrame for readability
X_scaled = pd.DataFrame(
    X_scaled,
    columns=feature_cols
)

# 6. Print churn distribution
print("Churn Distribution:")
print(y.value_counts())

print("\nChurn Percentage:")
print(y.value_counts(normalize=True) * 100)

# 7. Verify output
print("\nScaled Feature Shape:", X_scaled.shape)
print("\nFirst 5 Rows of Scaled Features:")
print(X_scaled.head())

