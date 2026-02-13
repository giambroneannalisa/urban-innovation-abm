import pandas as pd
import numpy as np

print("="*60)
print("  CONFRONTO RISULTATI OTTIMIZZAZIONE")
print("="*60)
print()

df = pd.read_csv("pareto_results_final.csv")
print(f"✅ File caricato: {len(df)} soluzioni trovate")
print()

innovation = -df['Obj_Innov_Neg']
diversity = -df['Obj_Div_Neg']
gini = df['Obj_Gini']

print("📊 STATISTICHE RISULTATI")
print("-"*60)

print(f"Innovazione Totale:")
print(f"  Min:     {innovation.min():>10,.0f}")
print(f"  Max:     {innovation.max():>10,.0f}")
print(f"  Media:   {innovation.mean():>10,.0f}")
print(f"  Mediana: {innovation.median():>10,.0f}")
print()

print(f"Diversità Culturale:")
print(f"  Min:     {diversity.min():>10.3f}")
print(f"  Max:     {diversity.max():>10.3f}")
print(f"  Media:   {diversity.mean():>10.3f}")
print(f"  Mediana: {diversity.median():>10.3f}")
print()

print(f"Coefficiente Gini:")
print(f"  Min:     {gini.min():>10.3f}")
print(f"  Max:     {gini.max():>10.3f}")
print(f"  Media:   {gini.mean():>10.3f}")
print(f"  Mediana: {gini.median():>10.3f}")
print()

print("-"*60)
print()

print("📌 CONFRONTO CON VALORI DI RIFERIMENTO")
print("-"*60)

ref_innovation = {'min': 245000, 'max': 562000}
ref_diversity = {'min': 0.52, 'max': 0.68}
ref_gini = {'min': 0.095, 'max': 0.148}

print("Innovazione:")
print(f"  Range atteso:   {ref_innovation['min']:>10,.0f} - {ref_innovation['max']:>10,.0f}")
print(f"  Range ottenuto: {innovation.min():>10,.0f} - {innovation.max():>10,.0f}")
innov_ok = (innovation.min() >= ref_innovation['min']*0.90 and innovation.max() <= ref_innovation['max']*1.10)
print(f"  {'✅ OK' if innov_ok else '⚠️  Fuori range'}")
print()

print("Diversità:")
print(f"  Range atteso:   {ref_diversity['min']:>10.3f} - {ref_diversity['max']:>10.3f}")
print(f"  Range ottenuto: {diversity.min():>10.3f} - {diversity.max():>10.3f}")
div_ok = (diversity.min() >= ref_diversity['min']*0.90 and diversity.max() <= ref_diversity['max']*1.10)
print(f"  {'✅ OK' if div_ok else '⚠️  Fuori range'}")
print()

print("Gini:")
print(f"  Range atteso:   {ref_gini['min']:>10.3f} - {ref_gini['max']:>10.3f}")
print(f"  Range ottenuto: {gini.min():>10.3f} - {gini.max():>10.3f}")
gini_ok = (gini.min() >= ref_gini['min']*0.90 and gini.max() <= ref_gini['max']*1.10)
print(f"  {'✅ OK' if gini_ok else '⚠️  Fuori range'}")
print()

print("="*60)
if innov_ok and div_ok and gini_ok:
    print("✅ TUTTI I VALORI NEL RANGE DI RIFERIMENTO!")
    print("✅ RISULTATI RIPRODUCIBILI - OK PER INVIO TESI")
else:
    print("⚠️  Alcuni valori fuori range")
print("="*60)
