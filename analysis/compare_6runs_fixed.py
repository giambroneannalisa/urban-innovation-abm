import pandas as pd
import numpy as np
import os

base_dir = os.path.expanduser('~/Downloads/000 grafici_e_pareto_results_final/')

files = [
    ('seed=1 #1', '34_pareto_results_final.csv'),
    ('seed=1 #2', '36_pareto_results_final.csv'),
    ('seed=1 #3', '23_pareto_results_final.csv'),
    ('seed=1 #4', '17_pareto_results_final.csv'),
    ('seed=1 #5', '24_pareto_results_final.csv'),
    ('seed=42 NEW', '42_pareto_results_final.csv')
]

results = []
print("="*70)
print("  COMPARISON: 5 RUNS (seed=1) vs NEW RUN (seed=42)")
print("="*70)

for label, fname in files:
    fpath = os.path.join(base_dir, fname)
    if not os.path.exists(fpath):
        print(f"⚠️  File non trovato: {fname}")
        continue
    
    df = pd.read_csv(fpath)
    
    # CONVERSIONE OBIETTIVI
    df['Innovation'] = -df['Obj_Innov_Neg']
    df['Diversity'] = -df['Obj_Div_Neg']
    
    results.append({
        'Run': label,
        'N_Solutions': len(df),
        'Innov_Max': df['Innovation'].max(),
        'Div_Max': df['Diversity'].max(),
        'Gini_Min': df['Obj_Gini'].min()
    })

summary = pd.DataFrame(results)

print("\n" + summary.to_string(index=False))

# CV per seed=1 (primi 5)
seed1 = summary.iloc[:5]
cv_seed1_innov = seed1['Innov_Max'].std() / seed1['Innov_Max'].mean() * 100
cv_seed1_div = seed1['Div_Max'].std() / seed1['Div_Max'].mean() * 100
cv_seed1_gini = seed1['Gini_Min'].std() / seed1['Gini_Min'].mean() * 100

# CV con seed=42 incluso
all_runs = summary
cv_all_innov = all_runs['Innov_Max'].std() / all_runs['Innov_Max'].mean() * 100
cv_all_div = all_runs['Div_Max'].std() / all_runs['Div_Max'].mean() * 100
cv_all_gini = all_runs['Gini_Min'].std() / all_runs['Gini_Min'].mean() * 100

print("\n" + "="*70)
print("CV% con solo seed=1 (primi 5 run):")
print(f"  Max Innovation: {cv_seed1_innov:.2f}%")
print(f"  Max Diversity:  {cv_seed1_div:.2f}%")
print(f"  Min Gini:       {cv_seed1_gini:.2f}%")

print(f"\nCV% includendo seed=42 (tutti i 6 run):")
print(f"  Max Innovation: {cv_all_innov:.2f}%")
print(f"  Max Diversity:  {cv_all_div:.2f}%")
print(f"  Min Gini:       {cv_all_gini:.2f}%")
print("="*70)

# INTERPRETAZIONE AUTOMATICA
print("\n🎯 INTERPRETAZIONE:")
if cv_all_innov > cv_seed1_innov * 1.5:
    print("   ✅ CV aumentato significativamente)
    print("   Il seed fisso stava riducendo la varianza artificialmente.")
    print("   Ora hai variabilità normale per ABM (range 8-15%).")
elif cv_all_innov > cv_seed1_innov * 1.2:
    print("   ✅ CV aumentato moderatamente.")
    print("   Effetto misto: sia seed fisso che stabilità intrinseca.")
    print("   Risultati robusti.")
elif cv_all_innov < cv_seed1_innov * 1.1:
    print("   🤔 CV rimane simile.")
    print("   Il modello è MOLTO stabile, non era solo il seed fisso.")
    print("   Scientificamente interessante (stabilità eccezionale).")
else:
    print("   ✅ CV leggermente aumentato.")
    print("   Variabilità entro range accettabile.")

print("="*70)
