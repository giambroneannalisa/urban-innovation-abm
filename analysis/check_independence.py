import pandas as pd
import os

base_dir = os.path.expanduser('~/Downloads/000 grafici_e_pareto_results_final/')
files = ['34_pareto_results_final.csv', '36_pareto_results_final.csv', 
         '23_pareto_results_final.csv', '17_pareto_results_final.csv', 
         '24_pareto_results_final.csv']

all_data = []
for i, fname in enumerate(files, 1):
    df = pd.read_csv(os.path.join(base_dir, fname))
    df['Run'] = i
    all_data.append(df)

combined = pd.concat(all_data, ignore_index=True)

print("="*60)
print("  TEST INDIPENDENZA RUN")
print("="*60)

# Test 1: Soluzioni duplicate tra run?
params = ['bridging-capital-weight', 'innovation-diffusion-rate', 
          'policy-effectiveness', 'cultural-diffusion-rate']
duplicates = combined.duplicated(subset=params, keep=False)
n_duplicates = duplicates.sum()

print(f"\n1. Soluzioni duplicate tra run: {n_duplicates}")
if n_duplicates > 0:
    print(f"   ⚠️  ATTENZIONE: {n_duplicates} soluzioni identiche trovate!")
    print(f"   Questo suggerisce che i run NON sono indipendenti.")
else:
    print(f"   ✅ OK: Tutte le 134 soluzioni sono uniche")

# Test 2: Correlazione tra run
print(f"\n2. Distribuzione soluzioni per run:")
print(combined['Run'].value_counts().sort_index())

# Test 3: Range parametri per run
print(f"\n3. Range bridging-capital-weight per run:")
for run in range(1, 6):
    subset = combined[combined['Run'] == run]
    bc_range = f"{subset['bridging-capital-weight'].min():.3f} - {subset['bridging-capital-weight'].max():.3f}"
    print(f"   Run {run}: {bc_range}")

# Test 4: Overlap significativo?
print(f"\n4. TEST CRITICO: Varianza INTRA-run vs INTER-run")
innovation = -combined['Obj_Innov_Neg']
combined['Innovation'] = innovation

# Varianza totale
total_var = innovation.var()

# Varianza tra run (between-group)
run_means = combined.groupby('Run')['Innovation'].mean()
grand_mean = innovation.mean()
between_var = sum([(m - grand_mean)**2 * len(combined[combined['Run']==i]) 
                   for i, m in enumerate(run_means, 1)]) / len(combined)

# Varianza dentro run (within-group)
within_var = total_var - between_var

print(f"   Varianza TOTALE:      {total_var:,.0f}")
print(f"   Varianza INTER-run:   {between_var:,.0f} ({between_var/total_var*100:.1f}%)")
print(f"   Varianza INTRA-run:   {within_var:,.0f} ({within_var/total_var*100:.1f}%)")

if between_var / total_var < 0.05:
    print(f"\n   ⚠️  RED FLAG: Varianza tra run < 5%")
    print(f"   I run potrebbero NON essere indipendenti!")
else:
    print(f"\n   ✅ OK: Varianza tra run è significativa")

print("="*60)
