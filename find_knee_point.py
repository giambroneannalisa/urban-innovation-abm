import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.spatial.distance import euclidean

df = pd.read_csv('pareto_results_final.csv')
df['Innovation'] = -df['Obj_Innov_Neg']
df['Diversity'] = -df['Obj_Div_Neg']
df['Gini'] = df['Obj_Gini']

objectives = df[['Innovation', 'Diversity', 'Gini']].copy()
objectives['Gini'] = 1 - objectives['Gini']
obj_norm = (objectives - objectives.min()) / (objectives.max() - objectives.min())

ideal_point = np.array([1, 1, 1])
df['dist_to_ideal'] = obj_norm.apply(lambda row: euclidean(row.values, ideal_point), axis=1)

knee_idx = df['dist_to_ideal'].idxmin()

print("="*70)
print("🎯 KNEE POINT - OPTIMAL COMPROMISE SOLUTION")
print("="*70)
print(f"\nSolution ID: {knee_idx}")
print(f"\nObjectives:")
print(f"  Innovation:  {df.loc[knee_idx, 'Innovation']:>10.0f}")
print(f"  Diversity:   {df.loc[knee_idx, 'Diversity']:>10.3f}")
print(f"  Gini:        {df.loc[knee_idx, 'Gini']:>10.3f}")
print(f"\nParameters:")
print(f"  Bridging:           {df.loc[knee_idx, 'bridging-capital-weight']:.3f}")
print(f"  Innov Diffusion:    {df.loc[knee_idx, 'innovation-diffusion-rate']:.3f}")
print(f"  Policy Effect:      {df.loc[knee_idx, 'policy-effectiveness']:.3f}")
print(f"  Cultural Diffusion: {df.loc[knee_idx, 'cultural-diffusion-rate']:.3f}")

fig = plt.figure(figsize=(15, 5))
ax1 = fig.add_subplot(131)
ax1.scatter(df['Innovation']/1000, df['Gini'], s=80, alpha=0.4)
ax1.scatter(df.loc[knee_idx, 'Innovation']/1000, df.loc[knee_idx, 'Gini'], 
           s=400, marker='*', color='red', edgecolors='black', linewidths=2, zorder=10)
ax1.set_xlabel('Innovation (x1000)')
ax1.set_ylabel('Gini')
ax1.set_title('KNEE POINT')
ax1.grid(True, alpha=0.3)

ax2 = fig.add_subplot(132, projection='3d')
ax2.scatter(df['Innovation']/1000, df['Diversity'], df['Gini'], s=80, alpha=0.4)
ax2.scatter(df.loc[knee_idx, 'Innovation']/1000, df.loc[knee_idx, 'Diversity'], 
           df.loc[knee_idx, 'Gini'], s=400, marker='*', color='red', zorder=10)
ax2.set_xlabel('Innovation')
ax2.set_ylabel('Diversity')
ax2.set_zlabel('Gini')

ax3 = fig.add_subplot(133)
sorted_dist = df.sort_values('dist_to_ideal')
ax3.barh(range(len(sorted_dist)), sorted_dist['dist_to_ideal'], alpha=0.6)
knee_position = sorted_dist.index.get_loc(knee_idx)
ax3.barh(knee_position, sorted_dist.loc[knee_idx, 'dist_to_ideal'], color='red')
ax3.set_xlabel('Distance to Ideal')
ax3.set_ylabel('Solution Rank')
ax3.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig('thesis_plots/Fig6_Knee_Point.png', dpi=300)
print("\n✅ Figure saved: thesis_plots/Fig6_Knee_Point.png")

df.loc[knee_idx].to_frame().T.to_csv('knee_point_solution.csv', index=False)
print("✅ Knee solution saved: knee_point_solution.csv")
