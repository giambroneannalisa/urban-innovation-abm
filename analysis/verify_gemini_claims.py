import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

print("="*70)
print("  VERIFICATION OF GEMINI CLAIMS - DEEP ANALYSIS")
print("="*70)

# Load all 6 runs
base_dir = Path('results/archive/')
files = list(base_dir.glob('*_pareto_results_final.csv'))

all_solutions = []
for f in files:
    df = pd.read_csv(f)
    df['Innovation'] = -df['Obj_Innov_Neg']
    df['Diversity'] = -df['Obj_Div_Neg']
    df['Gini'] = df['Obj_Gini']
    all_solutions.append(df)

combined = pd.concat(all_solutions, ignore_index=True)

print(f"\nTotal solutions analyzed: {len(combined)}")
print(f"Parameters: {[c for c in combined.columns if 'bridging' in c or 'diffusion' in c or 'policy' in c or 'cultural' in c]}")

# ============================================================================
# CLAIM 1: "No trade-off between Innovation and Diversity"
# ============================================================================
print("\n" + "="*70)
print("CLAIM 1: Innovation-Diversity Trade-off")
print("="*70)

correlation = combined[['Innovation', 'Diversity']].corr().iloc[0, 1]
print(f"\nCorrelation Innovation-Diversity: {correlation:.3f}")

# Find extremes
max_innov_sol = combined.loc[combined['Innovation'].idxmax()]
max_div_sol = combined.loc[combined['Diversity'].idxmax()]

print(f"\nMax Innovation solution:")
print(f"  Innovation: {max_innov_sol['Innovation']:,.0f}")
print(f"  Diversity: {max_innov_sol['Diversity']:.3f}")
print(f"  Gini: {max_innov_sol['Gini']:.3f}")

print(f"\nMax Diversity solution:")
print(f"  Innovation: {max_div_sol['Innovation']:,.0f}")
print(f"  Diversity: {max_div_sol['Diversity']:.3f}")
print(f"  Gini: {max_div_sol['Gini']:.3f}")

if correlation < -0.3:
    print("\n❌ CLAIM 1 FALSE: Strong negative correlation exists!")
    print("   Clear trade-off between Innovation and Diversity.")
elif correlation > -0.1:
    print("\n✅ CLAIM 1 TRUE: Weak/no correlation!")
    print("   Innovation and Diversity can be optimized together.")
else:
    print("\n⚠️  CLAIM 1 PARTIAL: Moderate negative correlation.")

# ============================================================================
# CLAIM 2: "Middle Ground achieves 80% of max innovation with Gini ~0.11"
# ============================================================================
print("\n" + "="*70)
print("CLAIM 2: Middle Ground Performance")
print("="*70)

# Define "Middle Ground" as solutions with Gini < 0.11
middle_ground = combined[combined['Gini'] <= 0.11]

if len(middle_ground) > 0:
    mg_max_innov = middle_ground['Innovation'].max()
    global_max_innov = combined['Innovation'].max()
    percentage = (mg_max_innov / global_max_innov) * 100
    
    print(f"\nGlobal max innovation: {global_max_innov:,.0f}")
    print(f"Middle Ground (Gini<=0.11) max innovation: {mg_max_innov:,.0f}")
    print(f"Percentage achieved: {percentage:.1f}%")
    print(f"Number of solutions with Gini<=0.11: {len(middle_ground)}")
    
    if abs(percentage - 80) < 10:
        print(f"\n✅ CLAIM 2 TRUE: {percentage:.1f}% ≈ 80%")
    else:
        print(f"\n❌ CLAIM 2 FALSE: {percentage:.1f}% ≠ 80%")
else:
    print("\n❌ No solutions with Gini <= 0.11 found!")

# ============================================================================
# CLAIM 3: "Cultural Diffusion Rate 42-68% for optimal results"
# ============================================================================
print("\n" + "="*70)
print("CLAIM 3: Cultural Diffusion Rate Range")
print("="*70)

# Check if column exists
param_cols = [c for c in combined.columns if 'cultural' in c.lower() and 'diffusion' in c.lower()]

if len(param_cols) > 0:
    param_name = param_cols[0]
    print(f"\nParameter found: '{param_name}'")
    
    # Analyze for Gini <= 0.11 solutions
    if len(middle_ground) > 0:
        mg_cultural = middle_ground[param_name]
        
        print(f"\nFor solutions with Gini <= 0.11:")
        print(f"  Cultural diffusion range: {mg_cultural.min():.3f} - {mg_cultural.max():.3f}")
        print(f"  Mean: {mg_cultural.mean():.3f}")
        print(f"  Median: {mg_cultural.median():.3f}")
        
        # Check if range overlaps with 0.42-0.68
        claimed_min, claimed_max = 0.42, 0.68
        actual_min, actual_max = mg_cultural.min(), mg_cultural.max()
        
        overlap = (max(claimed_min, actual_min) <= min(claimed_max, actual_max))
        
        if overlap and (actual_min <= 0.45 and actual_max >= 0.65):
            print(f"\n✅ CLAIM 3 TRUE: Range overlaps significantly with 42-68%")
        elif overlap:
            print(f"\n⚠️  CLAIM 3 PARTIAL: Some overlap but not exact match")
        else:
            print(f"\n❌ CLAIM 3 FALSE: No overlap with 42-68%")
            print(f"   Actual range: {actual_min*100:.1f}% - {actual_max*100:.1f}%")
else:
    print("\n❌ Cultural diffusion parameter not found in data!")

# ============================================================================
# DETAILED PARAMETER ANALYSIS
# ============================================================================
print("\n" + "="*70)
print("DETAILED PARAMETER RANGES FOR LOW GINI SOLUTIONS")
print("="*70)

if len(middle_ground) > 0:
    param_cols_all = [c for c in combined.columns if any(x in c.lower() 
                     for x in ['bridging', 'diffusion', 'policy', 'cultural'])]
    
    for col in param_cols_all:
        vals = middle_ground[col]
        print(f"\n{col}:")
        print(f"  Range: {vals.min():.3f} - {vals.max():.3f}")
        print(f"  Mean:  {vals.mean():.3f}")
        print(f"  Std:   {vals.std():.3f}")

# ============================================================================
# VISUALIZATIONS
# ============================================================================
print("\n" + "="*70)
print("Generating visualizations...")
print("="*70)

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Plot 1: Innovation vs Diversity (Trade-off)
ax = axes[0, 0]
scatter = ax.scatter(combined['Innovation'], combined['Diversity'], 
                    c=combined['Gini'], cmap='RdYlGn_r', alpha=0.6, s=50)
ax.set_xlabel('Innovation', fontsize=12)
ax.set_ylabel('Diversity', fontsize=12)
ax.set_title('Innovation-Diversity Trade-off\n(color = Gini)', fontsize=13, fontweight='bold')
plt.colorbar(scatter, ax=ax, label='Gini')

# Highlight extremes
ax.scatter(max_innov_sol['Innovation'], max_innov_sol['Diversity'], 
          color='red', s=200, marker='*', label='Max Innovation', edgecolor='black')
ax.scatter(max_div_sol['Innovation'], max_div_sol['Diversity'], 
          color='blue', s=200, marker='*', label='Max Diversity', edgecolor='black')
ax.legend()

# Plot 2: Innovation distribution for Low vs High Gini
ax = axes[0, 1]
low_gini = combined[combined['Gini'] <= 0.11]['Innovation']
high_gini = combined[combined['Gini'] > 0.11]['Innovation']

if len(low_gini) > 0 and len(high_gini) > 0:
    ax.hist(low_gini, bins=20, alpha=0.6, label='Gini ≤ 0.11', color='green')
    ax.hist(high_gini, bins=20, alpha=0.6, label='Gini > 0.11', color='orange')
    ax.set_xlabel('Innovation', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title('Innovation Distribution by Gini Level', fontsize=13, fontweight='bold')
    ax.legend()
    ax.axvline(low_gini.max(), color='green', linestyle='--', label='Max (Low Gini)')
    ax.axvline(combined['Innovation'].max(), color='red', linestyle='--', label='Global Max')

# Plot 3: Cultural Diffusion distribution
ax = axes[1, 0]
if len(param_cols) > 0:
    param = combined[param_cols[0]]
    param_mg = middle_ground[param_cols[0]] if len(middle_ground) > 0 else pd.Series()
    
    ax.hist(param, bins=30, alpha=0.5, label='All solutions', color='gray')
    if len(param_mg) > 0:
        ax.hist(param_mg, bins=30, alpha=0.7, label='Gini ≤ 0.11', color='green')
    
    # Mark claimed range 42-68%
    ax.axvspan(0.42, 0.68, alpha=0.2, color='blue', label='Claimed range (42-68%)')
    
    ax.set_xlabel('Cultural Diffusion Rate', fontsize=12)
    ax.set_ylabel('Frequency', fontsize=12)
    ax.set_title('Cultural Diffusion Distribution', fontsize=13, fontweight='bold')
    ax.legend()
else:
    ax.text(0.5, 0.5, 'Parameter not found', ha='center', va='center', transform=ax.transAxes)

# Plot 4: Pareto Front with Middle Ground highlighted
ax = axes[1, 1]
ax.scatter(combined['Innovation'], combined['Gini'], 
          alpha=0.4, s=30, color='gray', label='All solutions')
if len(middle_ground) > 0:
    ax.scatter(middle_ground['Innovation'], middle_ground['Gini'], 
              alpha=0.8, s=50, color='green', label='Gini ≤ 0.11 (Middle Ground)')

ax.set_xlabel('Innovation', fontsize=12)
ax.set_ylabel('Gini Coefficient', fontsize=12)
ax.set_title('Innovation vs Inequality\n(Middle Ground highlighted)', fontsize=13, fontweight='bold')
ax.axhline(0.11, color='red', linestyle='--', label='Gini = 0.11 threshold')
ax.legend()
ax.invert_yaxis()

plt.tight_layout()
plt.savefig('analysis/gemini_claims_verification.png', dpi=300, bbox_inches='tight')
print("\n✅ Figure saved: analysis/gemini_claims_verification.png")

# ============================================================================
# FINAL VERDICT
# ============================================================================
print("\n" + "="*70)
print("FINAL VERDICT ON GEMINI CLAIMS")
print("="*70)

verdicts = []

# Claim 1
if correlation < -0.3:
    verdicts.append("❌ CLAIM 1 (No trade-off): FALSE - Trade-off exists")
else:
    verdicts.append("✅ CLAIM 1 (No trade-off): TRUE/PARTIAL")

# Claim 2
if len(middle_ground) > 0:
    if abs(percentage - 80) < 10:
        verdicts.append(f"✅ CLAIM 2 (80% performance): TRUE ({percentage:.1f}%)")
    else:
        verdicts.append(f"❌ CLAIM 2 (80% performance): FALSE ({percentage:.1f}% ≠ 80%)")
else:
    verdicts.append("❌ CLAIM 2: Cannot verify")

# Claim 3
if len(param_cols) > 0 and len(middle_ground) > 0:
    if overlap and (actual_min <= 0.45 and actual_max >= 0.65):
        verdicts.append("✅ CLAIM 3 (42-68% cultural diffusion): TRUE")
    else:
        verdicts.append(f"❌ CLAIM 3 (42-68% cultural diffusion): FALSE (actual: {actual_min*100:.0f}-{actual_max*100:.0f}%)")
else:
    verdicts.append("❌ CLAIM 3: Cannot verify - parameter not found")

for v in verdicts:
    print(f"\n{v}")

print("\n" + "="*70)
print("Analysis complete. Check analysis/gemini_claims_verification.png")
print("="*70)
