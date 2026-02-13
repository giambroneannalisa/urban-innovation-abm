import pandas as pd
import numpy as np
import os

base_dir = os.path.expanduser('~/Downloads/000 grafici_e_pareto_results_final/')
files = [
    os.path.join(base_dir, '34_pareto_results_final.csv'),
    os.path.join(base_dir, '36_pareto_results_final.csv'),
    os.path.join(base_dir, '23_pareto_results_final.csv'),
    os.path.join(base_dir, '17_pareto_results_final.csv'),
    os.path.join(base_dir, '24_pareto_results_final.csv')
]

results = []
for i, file in enumerate(files, 1):
    df = pd.read_csv(file)
    df['Innovation'] = -df['Obj_Innov_Neg']
    df['Diversity'] = -df['Obj_Div_Neg']
    df['Gini'] = df['Obj_Gini']
    
    results.append({
        'Run': i,
        'N_Solutions': len(df),
        'Innov_Min': df['Innovation'].min(),
        'Innov_Max': df['Innovation'].max(),
        'Innov_Mean': df['Innovation'].mean(),
        'Div_Min': df['Diversity'].min(),
        'Div_Max': df['Diversity'].max(),
        'Div_Mean': df['Diversity'].mean(),
        'Gini_Min': df['Gini'].min(),
        'Gini_Max': df['Gini'].max(),
        'Gini_Mean': df['Gini'].mean()
    })

summary = pd.DataFrame(results)
cv_innov_max = summary['Innov_Max'].std() / summary['Innov_Max'].mean() * 100
cv_div_max = summary['Div_Max'].std() / summary['Div_Max'].mean() * 100
cv_gini_min = summary['Gini_Min'].std() / summary['Gini_Min'].mean() * 100

print("="*60)
print("  ROBUSTNESS ANALYSIS - 5 INDEPENDENT RUNS")
print("="*60)
print(summary.to_string(index=False))
print("\n" + "="*60)
print(f"Coefficient of Variation (CV%):")
print(f"  Max Innovation:    {cv_innov_max:.2f}%")
print(f"  Max Diversity:     {cv_div_max:.2f}%")
print(f"  Min Gini:          {cv_gini_min:.2f}%")
print("="*60)
