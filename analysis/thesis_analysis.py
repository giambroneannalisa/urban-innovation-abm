import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

# ========== CARICA DATI ==========
print("="*70)
print("📊 PARETO FRONT ANALYSIS FOR PHD THESIS")
print("="*70)

df = pd.read_csv('pareto_results_final.csv')

# Inverti segni (erano negati per minimizzazione NSGA-II)
df['Innovation'] = -df['Obj_Innov_Neg']
df['Diversity'] = -df['Obj_Div_Neg']
df['Gini'] = df['Obj_Gini']

# Abbrevia nomi parametri per leggibilità
df = df.rename(columns={
    'bridging-capital-weight': 'Bridging',
    'innovation-diffusion-rate': 'Innov_Diff',
    'policy-effectiveness': 'Policy',
    'cultural-diffusion-rate': 'Cultural_Diff'
})

param_cols = ['Bridging', 'Innov_Diff', 'Policy', 'Cultural_Diff']
obj_cols = ['Innovation', 'Diversity', 'Gini']

# ========== STATISTICHE BASE ==========
print(f"\n✅ Number of Pareto-optimal solutions: {len(df)}")
print("\n" + "="*70)
print("OBJECTIVE RANGES")
print("="*70)

for obj in obj_cols:
    print(f"{obj:12s}: {df[obj].min():>10.2f} - {df[obj].max():>10.2f}  (range: {df[obj].max()-df[obj].min():>10.2f})")

print("\n" + "="*70)
print("PARAMETER RANGES")
print("="*70)

for param in param_cols:
    print(f"{param:15s}: {df[param].min():.3f} - {df[param].max():.3f}")

# ========== IDENTIFICA SOLUZIONI ESTREME ==========
print("\n" + "="*70)
print("🎯 EXTREME SOLUTIONS (Archetypes)")
print("="*70)

extremes = {
    'Max Innovation': df.loc[df['Innovation'].idxmax()],
    'Max Diversity': df.loc[df['Diversity'].idxmax()],
    'Min Gini (Max Equity)': df.loc[df['Gini'].idxmin()]
}

for name, sol in extremes.items():
    print(f"\n📍 {name}:")
    print(f"   Objectives:")
    print(f"     Innovation: {sol['Innovation']:>10.0f}")
    print(f"     Diversity:  {sol['Diversity']:>10.3f}")
    print(f"     Gini:       {sol['Gini']:>10.3f}")
    print(f"   Parameters:")
    for param in param_cols:
        print(f"     {param:15s}: {sol[param]:.3f}")

# ========== CLUSTERING ==========
print("\n" + "="*70)
print("🔍 CLUSTERING ANALYSIS (K-Means, k=4)")
print("="*70)

# Standardizza e clusterizza
scaler = StandardScaler()
X = scaler.fit_transform(df[obj_cols])
kmeans = KMeans(n_clusters=4, random_state=42, n_init=10)
df['Cluster'] = kmeans.fit_predict(X)

# Assegna nomi basati su caratteristiche
cluster_profiles = []
for cluster_id in range(4):
    cluster_df = df[df['Cluster'] == cluster_id]
    avg_innov = cluster_df['Innovation'].mean()
    avg_div = cluster_df['Diversity'].mean()
    avg_gini = cluster_df['Gini'].mean()
    
    # Logica di naming
    if avg_gini < 0.113:
        name = "🟢 Equitable City"
    elif avg_innov > 480000:
        name = "🔴 Innovation Hub"
    elif avg_div > 0.61:
        name = "🟡 Diverse Metropolis"
    else:
        name = "🔵 Balanced City"
    
    cluster_profiles.append({
        'id': cluster_id,
        'name': name,
        'count': len(cluster_df),
        'innov': avg_innov,
        'div': avg_div,
        'gini': avg_gini
    })

# Ordina per innovazione decrescente
cluster_profiles.sort(key=lambda x: x['innov'], reverse=True)

for profile in cluster_profiles:
    print(f"\n{profile['name']} (Cluster {profile['id']}, n={profile['count']}):")
    print(f"   Avg Innovation: {profile['innov']:>10.0f}")
    print(f"   Avg Diversity:  {profile['div']:>10.3f}")
    print(f"   Avg Gini:       {profile['gini']:>10.3f}")
    
    # Parametri tipici
    cluster_df = df[df['Cluster'] == profile['id']]
    print(f"   Typical Parameters:")
    for param in param_cols:
        print(f"     {param:15s}: {cluster_df[param].mean():.3f}")

# ========== TRADE-OFF ANALYSIS ==========
print("\n" + "="*70)
print("⚖️ TRADE-OFF QUANTIFICATION")
print("="*70)

max_innov = df['Innovation'].max()
max_innov_sol = df.loc[df['Innovation'].idxmax()]

min_gini = df['Gini'].min()
min_gini_sol = df.loc[df['Gini'].idxmin()]

equity_cost_abs = max_innov - min_gini_sol['Innovation']
equity_cost_pct = (equity_cost_abs / max_innov) * 100

print(f"\n1️⃣ THE COST OF EQUITY:")
print(f"   Max Innovation achievable:     {max_innov:>10.0f}")
print(f"   Innovation at Min Gini:        {min_gini_sol['Innovation']:>10.0f}")
print(f"   Absolute loss:                 {equity_cost_abs:>10.0f}")
print(f"   Percentage loss:               {equity_cost_pct:>10.1f}%")
print(f"   ")
print(f"   Interpretation: Reducing inequality from {max_innov_sol['Gini']:.3f}")
print(f"   to {min_gini:.3f} costs {equity_cost_pct:.1f}% of innovation output.")

# Diversità
max_div = df['Diversity'].max()
max_div_sol = df.loc[df['Diversity'].idxmax()]

div_tradeoff = max_innov - max_div_sol['Innovation']
div_tradeoff_pct = (div_tradeoff / max_innov) * 100

print(f"\n2️⃣ THE DIVERSITY PARADOX:")
print(f"   Max Diversity:                 {max_div:>10.3f}")
print(f"   Innovation at Max Diversity:   {max_div_sol['Innovation']:>10.0f}")
print(f"   Innovation loss vs max:        {div_tradeoff:>10.0f} ({div_tradeoff_pct:.1f}%)")
print(f"   ")
print(f"   Interpretation: Maximum diversity ({max_div:.3f}) is associated")
print(f"   with moderate innovation, suggesting potential fragmentation effects.")

# ========== CORRELAZIONI ==========
print("\n" + "="*70)
print("📈 PARAMETER-OBJECTIVE CORRELATIONS")
print("="*70)

corr_matrix = df[param_cols + obj_cols].corr()

print("\nCorrelation with Innovation:")
for param in param_cols:
    corr = corr_matrix.loc[param, 'Innovation']
    direction = "↑ Positive" if corr > 0 else "↓ Negative"
    strength = "Strong" if abs(corr) > 0.5 else "Moderate" if abs(corr) > 0.3 else "Weak"
    print(f"  {param:20s}: {corr:>6.3f}  ({strength} {direction})")

print("\nCorrelation with Diversity:")
for param in param_cols:
    corr = corr_matrix.loc[param, 'Diversity']
    direction = "↑ Positive" if corr > 0 else "↓ Negative"
    strength = "Strong" if abs(corr) > 0.5 else "Moderate" if abs(corr) > 0.3 else "Weak"
    print(f"  {param:20s}: {corr:>6.3f}  ({strength} {direction})")

print("\nCorrelation with Gini (lower = more equitable):")
for param in param_cols:
    corr = corr_matrix.loc[param, 'Gini']
    direction = "↑ Increases inequality" if corr > 0 else "↓ Reduces inequality"
    strength = "Strong" if abs(corr) > 0.5 else "Moderate" if abs(corr) > 0.3 else "Weak"
    print(f"  {param:20s}: {corr:>6.3f}  ({strength} {direction})")

# ========== VISUALIZZAZIONI ==========
print("\n" + "="*70)
print("📊 CREATING VISUALIZATIONS...")
print("="*70)

# Figure 1: Overview (3 subplots)
fig = plt.figure(figsize=(18, 6))

# Subplot 1: Innovation vs Gini
ax1 = fig.add_subplot(131)
for cluster_id in range(4):
    cluster_df = df[df['Cluster'] == cluster_id]
    profile = [p for p in cluster_profiles if p['id'] == cluster_id][0]
    ax1.scatter(cluster_df['Innovation']/1000, cluster_df['Gini'], 
                label=profile['name'], s=120, alpha=0.7)
ax1.set_xlabel('Innovation (×1000)', fontsize=12, fontweight='bold')
ax1.set_ylabel('Gini Coefficient\n(lower = more equitable)', fontsize=12, fontweight='bold')
ax1.set_title('Trade-off: Innovation vs Equity', fontsize=14, fontweight='bold')
ax1.legend(loc='best', fontsize=9)
ax1.grid(True, alpha=0.3)

# Subplot 2: Innovation vs Diversity
ax2 = fig.add_subplot(132)
for cluster_id in range(4):
    cluster_df = df[df['Cluster'] == cluster_id]
    profile = [p for p in cluster_profiles if p['id'] == cluster_id][0]
    ax2.scatter(cluster_df['Innovation']/1000, cluster_df['Diversity'], 
                label=profile['name'], s=120, alpha=0.7)
ax2.set_xlabel('Innovation (×1000)', fontsize=12, fontweight='bold')
ax2.set_ylabel('Cultural Diversity\n(Shannon Index)', fontsize=12, fontweight='bold')
ax2.set_title('Trade-off: Innovation vs Diversity', fontsize=14, fontweight='bold')
ax2.legend(loc='best', fontsize=9)
ax2.grid(True, alpha=0.3)

# Subplot 3: Diversity vs Gini
ax3 = fig.add_subplot(133)
for cluster_id in range(4):
    cluster_df = df[df['Cluster'] == cluster_id]
    profile = [p for p in cluster_profiles if p['id'] == cluster_id][0]
    ax3.scatter(cluster_df['Diversity'], cluster_df['Gini'], 
                label=profile['name'], s=120, alpha=0.7)
ax3.set_xlabel('Cultural Diversity', fontsize=12, fontweight='bold')
ax3.set_ylabel('Gini Coefficient', fontsize=12, fontweight='bold')
ax3.set_title('Trade-off: Diversity vs Equity', fontsize=14, fontweight='bold')
ax3.legend(loc='best', fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('Fig1_Pareto_Front_Overview.png', dpi=300, bbox_inches='tight')
print("✅ Saved: Fig1_Pareto_Front_Overview.png")

# Figure 2: Parameter Heatmap
fig, ax = plt.subplots(figsize=(10, 8))
sns.heatmap(corr_matrix, annot=True, fmt='.2f', cmap='RdBu_r', center=0,
            square=True, linewidths=1, cbar_kws={"shrink": 0.8}, ax=ax)
ax.set_title('Parameter-Objective Correlation Matrix', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('Fig2_Correlation_Heatmap.png', dpi=300, bbox_inches='tight')
print("✅ Saved: Fig2_Correlation_Heatmap.png")

# Figure 3: Parallel Coordinates (Plotly)
try:
    import plotly.express as px
    
    fig_parallel = px.parallel_coordinates(
        df, 
        dimensions=param_cols + obj_cols,
        color="Innovation",
        color_continuous_scale=px.colors.diverging.RdYlGn,
        title="Policy Parameters → Urban Outcomes (Interactive Pareto Front)"
    )
    fig_parallel.update_layout(
        font=dict(size=14),
        margin=dict(l=80, r=80, t=100, b=50)
    )
    fig_parallel.write_html("Fig3_Parallel_Coordinates.html")
    print("✅ Saved: Fig3_Parallel_Coordinates.html (open in browser!)")
except ImportError:
    print("⚠️  plotly not installed, skipping parallel coordinates")

# ========== SALVA RISULTATI ==========
df.to_csv('pareto_results_analyzed.csv', index=False)
print("\n✅ Saved: pareto_results_analyzed.csv (with cluster assignments)")

print("\n" + "="*70)
print("📁 SUMMARY OF OUTPUT FILES")
print("="*70)
print("  1. Fig1_Pareto_Front_Overview.png      (3 trade-off plots)")
print("  2. Fig2_Correlation_Heatmap.png        (parameter relationships)")
print("  3. Fig3_Parallel_Coordinates.html      (interactive exploration)")
print("  4. pareto_results_analyzed.csv         (data + clusters)")
print("\n🎉 Analysis complete! Ready for thesis writing.")
print("="*70)
