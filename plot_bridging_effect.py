import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

OUTPUT_DIR = 'thesis_plots'
df = pd.read_csv('pareto_results_analyzed.csv')
df['Innovation'] = -df['Obj_Innov_Neg']
df['Diversity'] = -df['Obj_Div_Neg']
df['Gini'] = df['Obj_Gini']
bridging_col = 'Bridging'

fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111, projection='3d')
scatter = ax.scatter(df[bridging_col], df['Innovation']/1000, df['Gini'], c=df['Diversity'], cmap='viridis', s=150, alpha=0.7)
ax.set_xlabel('Bridging Capital', fontsize=12)
ax.set_ylabel('Innovation (x1000)', fontsize=12)
ax.set_zlabel('Gini Coefficient', fontsize=12)
plt.colorbar(scatter, ax=ax, shrink=0.5, label='Diversity')
plt.savefig(f'{OUTPUT_DIR}/Fig4_Bridging_Tradeoff.png', dpi=300)
print('Fig4 saved')

fig, axes = plt.subplots(1, 3, figsize=(18, 5))
sns.regplot(x=bridging_col, y='Innovation', data=df, ax=axes[0], color='blue', order=2)
sns.regplot(x=bridging_col, y='Gini', data=df, ax=axes[1], color='red', order=2)
sns.regplot(x=bridging_col, y='Diversity', data=df, ax=axes[2], color='green', order=2)
plt.tight_layout()
plt.savefig(f'{OUTPUT_DIR}/Fig5_Bridging_Panel.png', dpi=300)
print('Fig5 saved')
