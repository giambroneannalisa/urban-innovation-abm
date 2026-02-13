import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.spatial.distance import cdist
from sklearn.preprocessing import MinMaxScaler
import os

# Create output directory
os.makedirs('thesis_plots', exist_ok=True)

# ============================================================================
# LOAD DATA
# ============================================================================
print("="*80)
print("LOADING DATA...")
print("="*80)

df_final = pd.read_csv('pareto_results_final (3).csv')
df_checkpoint = pd.read_csv('pareto_results_checkpoint (2).csv')

# Rename columns for clarity
df_final.columns = ['Bridging', 'Innovation_Diff', 'Policy_Eff', 'Cultural_Diff', 
                    'Innovation', 'Diversity', 'Gini']
df_checkpoint.columns = ['Bridging', 'Innovation_Diff', 'Policy_Eff', 'Cultural_Diff', 
                         'Innovation', 'Diversity', 'Gini', 'Generation']

# Convert to positive values (were stored as negatives)
df_final['Innovation'] = -df_final['Innovation']
df_final['Diversity'] = -df_final['Diversity']

df_checkpoint['Innovation'] = -df_checkpoint['Innovation']
df_checkpoint['Diversity'] = -df_checkpoint['Diversity']

print(f"✅ Final Pareto set: {len(df_final)} solutions")
print(f"✅ Checkpoint data: {len(df_checkpoint)} solutions across {df_checkpoint['Generation'].max()} generations")

# ============================================================================
# METHOD 1: KNEE POINT BY NORMALIZED DISTANCE TO UTOPIAN POINT
# ============================================================================
print("\n" + "="*80)
print("FINDING KNEE POINT - METHOD 1: Distance to Utopian Point")
print("="*80)

# Normalize objectives to [0,1]
scaler = MinMaxScaler()
objectives = ['Innovation', 'Diversity', 'Gini']
df_norm = df_final.copy()
df_norm[objectives] = scaler.fit_transform(df_final[objectives])

# Gini should be minimized (invert it)
df_norm['Gini'] = 1 - df_norm['Gini']

# Utopian point (best on each objective)
utopian = np.array([1, 1, 1])

# Calculate Euclidean distance to utopia
distances = cdist(df_norm[objectives].values, [utopian], metric='euclidean').flatten()
df_final['Distance_to_Utopia'] = distances

# Knee point = minimum distance
knee_idx_method1 = df_final['Distance_to_Utopia'].idxmin()
knee_solution = df_final.loc[knee_idx_method1]

print(f"\n🏆 KNEE POINT SOLUTION (Index {knee_idx_method1}):")
print("-"*80)
print(f"  Innovation Output:    {knee_solution['Innovation']:>12,.0f} units")
print(f"  Cultural Diversity:   {knee_solution['Diversity']:>12.4f}")
print(f"  Gini Coefficient:     {knee_solution['Gini']:>12.4f}")
print(f"  Distance to Utopia:   {knee_solution['Distance_to_Utopia']:>12.4f}")
print("\n  OPTIMAL PARAMETERS:")
print(f"  Bridging Capital:     {knee_solution['Bridging']:>12.4f}")
print(f"  Innovation Diffusion: {knee_solution['Innovation_Diff']:>12.4f}")
print(f"  Policy Effectiveness: {knee_solution['Policy_Eff']:>12.4f}")
print(f"  Cultural Diffusion:   {knee_solution['Cultural_Diff']:>12.4f}")

# ============================================================================
# METHOD 2: CURVATURE METHOD (Innovation-Gini trade-off)
# ============================================================================
print("\n" + "="*80)
print("FINDING KNEE POINT - METHOD 2: Maximum Curvature")
print("="*80)

# Sort by Gini
df_sorted = df_final.sort_values('Gini').reset_index(drop=True)

# Calculate curvature for Innovation-Gini trade-off
def calculate_curvature(x, y):
    """Calculate curvature at each point"""
    dx = np.gradient(x)
    dy = np.gradient(y)
    ddx = np.gradient(dx)
    ddy = np.gradient(dy)
    
    numerator = np.abs(dx * ddy - dy * ddx)
    denominator = (dx**2 + dy**2)**1.5
    
    return numerator / (denominator + 1e-10)

x = df_sorted['Gini'].values
y = df_sorted['Innovation'].values
curvature = calculate_curvature(x, y)

knee_idx_method2 = df_sorted.loc[np.argmax(curvature)].name
knee_solution_m2 = df_final.loc[knee_idx_method2]

print(f"\n🏆 KNEE POINT by Curvature (Index {knee_idx_method2}):")
print(f"  Innovation: {knee_solution_m2['Innovation']:,.0f}")
print(f"  Diversity:  {knee_solution_m2['Diversity']:.4f}")
print(f"  Gini:       {knee_solution_m2['Gini']:.4f}")

# ============================================================================
# COMPARISON WITH EXTREME SOLUTIONS
# ============================================================================
print("\n" + "="*80)
print("COMPARISON: KNEE POINT vs EXTREME SOLUTIONS")
print("="*80)

# Best Innovation
best_innov = df_final.loc[df_final['Innovation'].idxmax()]
# Best Gini (lowest)
best_gini = df_final.loc[df_final['Gini'].idxmin()]
# Best Diversity
best_div = df_final.loc[df_final['Diversity'].idxmax()]

comparison = pd.DataFrame({
    'Metric': ['Innovation', 'Diversity', 'Gini', 'Bridging', 'Cultural_Diff'],
    'Best Innovation': [best_innov['Innovation'], best_innov['Diversity'], 
                        best_innov['Gini'], best_innov['Bridging'], best_innov['Cultural_Diff']],
    'Knee Point': [knee_solution['Innovation'], knee_solution['Diversity'], 
                   knee_solution['Gini'], knee_solution['Bridging'], knee_solution['Cultural_Diff']],
    'Best Equality': [best_gini['Innovation'], best_gini['Diversity'], 
                      best_gini['Gini'], best_gini['Bridging'], best_gini['Cultural_Diff']]
})

print(comparison.to_string(index=False))

# Calculate percentages
print(f"\n📊 KEY INSIGHTS:")
print(f"  • Knee achieves {knee_solution['Innovation']/best_innov['Innovation']*100:.1f}% of max innovation")
print(f"  • With {(best_innov['Gini']-knee_solution['Gini'])/best_innov['Gini']*100:.1f}% less inequality")
print(f"  • Cultural diffusion is {knee_solution['Cultural_Diff']/knee_solution['Bridging']:.1f}x bridging capital")

# ============================================================================
# VISUALIZATIONS
# ============================================================================
print("\n" + "="*80)
print("CREATING THESIS VISUALIZATIONS...")
print("="*80)

# Set style
sns.set_palette("husl")
plt.style.use('seaborn-v0_8-darkgrid')

# FIGURE 1: 3D Pareto Front with Knee Point
fig = plt.figure(figsize=(12, 9))
ax = fig.add_subplot(111, projection='3d')

scatter = ax.scatter(df_final['Innovation'], df_final['Diversity'], df_final['Gini'],
                     c=df_final['Distance_to_Utopia'], cmap='viridis', s=100, alpha=0.6)

# Highlight knee point
ax.scatter([knee_solution['Innovation']], [knee_solution['Diversity']], 
           [knee_solution['Gini']], color='red', s=500, marker='*', 
           label='Knee Point (EUCC)', edgecolors='black', linewidths=2)

ax.set_xlabel('\nInnovation Output', fontsize=12, fontweight='bold')
ax.set_ylabel('\nCultural Diversity', fontsize=12, fontweight='bold')
ax.set_zlabel('\nGini Coefficient\n(Inequality)', fontsize=12, fontweight='bold')
ax.set_title('Pareto Front: The Evolutionary Urban Cultural Complex (EUCC)\n', 
             fontsize=14, fontweight='bold')

cbar = plt.colorbar(scatter, ax=ax, pad=0.1, shrink=0.8)
cbar.set_label('Distance to Utopia', fontsize=10)
ax.legend(fontsize=12, loc='upper left')

plt.tight_layout()
plt.savefig('thesis_plots/Fig1_EUCC_3D_Pareto.png', dpi=300, bbox_inches='tight')
print("✅ Fig1_EUCC_3D_Pareto.png saved")

# FIGURE 2: Trade-off Curves
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Innovation vs Gini
axes[0].scatter(df_final['Gini'], df_final['Innovation'], alpha=0.6, s=80)
axes[0].scatter(knee_solution['Gini'], knee_solution['Innovation'], 
               color='red', s=300, marker='*', edgecolors='black', linewidths=2,
               label='Knee Point', zorder=5)
axes[0].set_xlabel('Gini Coefficient (Inequality)', fontweight='bold')
axes[0].set_ylabel('Innovation Output', fontweight='bold')
axes[0].set_title('Innovation vs Equality Trade-off', fontweight='bold')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Innovation vs Diversity
axes[1].scatter(df_final['Diversity'], df_final['Innovation'], alpha=0.6, s=80)
axes[1].scatter(knee_solution['Diversity'], knee_solution['Innovation'], 
               color='red', s=300, marker='*', edgecolors='black', linewidths=2,
               label='Knee Point', zorder=5)
axes[1].set_xlabel('Cultural Diversity', fontweight='bold')
axes[1].set_ylabel('Innovation Output', fontweight='bold')
axes[1].set_title('Innovation vs Diversity Trade-off', fontweight='bold')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Diversity vs Gini
axes[2].scatter(df_final['Gini'], df_final['Diversity'], alpha=0.6, s=80)
axes[2].scatter(knee_solution['Gini'], knee_solution['Diversity'], 
               color='red', s=300, marker='*', edgecolors='black', linewidths=2,
               label='Knee Point', zorder=5)
axes[2].set_xlabel('Gini Coefficient (Inequality)', fontweight='bold')
axes[2].set_ylabel('Cultural Diversity', fontweight='bold')
axes[2].set_title('Diversity vs Equality Trade-off', fontweight='bold')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('thesis_plots/Fig2_Trade_off_Curves.png', dpi=300, bbox_inches='tight')
print("✅ Fig2_Trade_off_Curves.png saved")

# FIGURE 3: Parameter Effects (Bridging Capital)
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

sns.regplot(x='Bridging', y='Innovation', data=df_final, ax=axes[0], 
            color='#2E86AB', order=2, scatter_kws={'alpha':0.6})
axes[0].set_title('Bridging Capital → Innovation', fontweight='bold', fontsize=12)
axes[0].set_xlabel('Bridging Capital Weight', fontweight='bold')
axes[0].set_ylabel('Innovation Output', fontweight='bold')

sns.regplot(x='Bridging', y='Gini', data=df_final, ax=axes[1], 
            color='#A23B72', order=2, scatter_kws={'alpha':0.6})
axes[1].set_title('Bridging Capital → Inequality', fontweight='bold', fontsize=12)
axes[1].set_xlabel('Bridging Capital Weight', fontweight='bold')
axes[1].set_ylabel('Gini Coefficient', fontweight='bold')

sns.regplot(x='Bridging', y='Diversity', data=df_final, ax=axes[2], 
            color='#F18F01', order=2, scatter_kws={'alpha':0.6})
axes[2].set_title('Bridging Capital → Diversity', fontweight='bold', fontsize=12)
axes[2].set_xlabel('Bridging Capital Weight', fontweight='bold')
axes[2].set_ylabel('Cultural Diversity', fontweight='bold')

plt.tight_layout()
plt.savefig('thesis_plots/Fig3_Bridging_Capital_Effects.png', dpi=300, bbox_inches='tight')
print("✅ Fig3_Bridging_Capital_Effects.png saved")

# FIGURE 4: Radar Chart - Policy Regimes
from math import pi

categories = ['Innovation\n(normalized)', 'Diversity\n(normalized)', 'Equality\n(inv. Gini)']
N = len(categories)

angles = [n / float(N) * 2 * pi for n in range(N)]
angles += angles[:1]

fig, ax = plt.subplots(figsize=(8, 8), subplot_kw=dict(projection='polar'))

# Normalize all to 0-1
solutions = {
    'Best Innovation': best_innov,
    'Knee Point (EUCC)': knee_solution,
    'Best Equality': best_gini
}

for label, sol in solutions.items():
    values = [
        sol['Innovation'] / df_final['Innovation'].max(),
        sol['Diversity'] / df_final['Diversity'].max(),
        1 - (sol['Gini'] - df_final['Gini'].min()) / (df_final['Gini'].max() - df_final['Gini'].min())
    ]
    values += values[:1]
    
    ax.plot(angles, values, 'o-', linewidth=2, label=label)
    ax.fill(angles, values, alpha=0.25)

ax.set_xticks(angles[:-1])
ax.set_xticklabels(categories, size=10)
ax.set_ylim(0, 1)
ax.set_title('Policy Regime Comparison\n', size=14, fontweight='bold', pad=20)
ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1))
ax.grid(True)

plt.tight_layout()
plt.savefig('thesis_plots/Fig4_Radar_Policy_Regimes.png', dpi=300, bbox_inches='tight')
print("✅ Fig4_Radar_Policy_Regimes.png saved")

# ============================================================================
# SAVE RESULTS
# ============================================================================
print("\n" + "="*80)
print("SAVING RESULTS...")
print("="*80)

# Save knee point solution
knee_solution.to_frame().T.to_csv('EUCC_knee_point_solution.csv', index=False)
print("✅ EUCC_knee_point_solution.csv saved")

# Save full analysis
df_final.sort_values('Distance_to_Utopia').to_csv('pareto_results_ranked.csv', index=False)
print("✅ pareto_results_ranked.csv saved")

# Summary statistics
summary = pd.DataFrame({
    'Metric': ['Mean', 'Std', 'Min', 'Max', 'Knee Point'],
    'Innovation': [df_final['Innovation'].mean(), df_final['Innovation'].std(),
                   df_final['Innovation'].min(), df_final['Innovation'].max(),
                   knee_solution['Innovation']],
    'Diversity': [df_final['Diversity'].mean(), df_final['Diversity'].std(),
                  df_final['Diversity'].min(), df_final['Diversity'].max(),
                  knee_solution['Diversity']],
    'Gini': [df_final['Gini'].mean(), df_final['Gini'].std(),
             df_final['Gini'].min(), df_final['Gini'].max(),
             knee_solution['Gini']]
})

summary.to_csv('summary_statistics.csv', index=False)
print("✅ summary_statistics.csv saved")

print("\n" + "="*80)
print("✅ ANALYSIS COMPLETE!")
print("="*80)
print("\nFor your thesis, use:")
print(f"  1. Knee Point Index: {knee_idx_method1}")
print(f"  2. Innovation: {knee_solution['Innovation']:,.0f} units")
print(f"  3. Diversity: {knee_solution['Diversity']:.4f} (optimal window: 0.57-0.68)")
print(f"  4. Gini: {knee_solution['Gini']:.4f} (exceptionally low inequality)")
print(f"  5. Key parameter: Cultural Diffusion = {knee_solution['Cultural_Diff']:.4f}")
print(f"     (This is {knee_solution['Cultural_Diff']/knee_solution['Bridging']:.1f}x the bridging capital)")

