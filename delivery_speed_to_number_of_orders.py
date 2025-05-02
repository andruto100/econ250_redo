import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from google.cloud import bigquery
from scipy.stats import pearsonr

client = bigquery.Client()
query = """
SELECT *
FROM `econ250-2025.AD_Redo.customer_delivery_sensitivity`
"""
df = client.query(query).to_dataframe()

df['fast_pct'] = df['fast_count'] / df['total_orders']



sns.lmplot(data=df, x='total_orders', y='avg_delivery_score', ci=None)
plt.title('Regression: Order Count vs. Delivery Score')
plt.xlabel('Total Orders')
plt.ylabel('Average Delivery Score')
plt.tight_layout()
plt.show()


corr, p_value = pearsonr(df['total_orders'], df['avg_delivery_score'])
print(f"Correlation between total orders and average delivery score: {corr:.2f} (p={p_value:.4f})")