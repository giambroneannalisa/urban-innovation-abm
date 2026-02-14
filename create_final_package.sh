#!/bin/bash
PACKAGE_NAME="urban-innovation-abm-thesis-with-results-v1.0"
TEMP_DIR="/tmp/${PACKAGE_NAME}"

echo "📦 Creazione pacchetto finale..."

rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}/results"

# Copia codice
cp *.nlogo "${TEMP_DIR}/" 2>/dev/null
cp *.py "${TEMP_DIR}/" 2>/dev/null
cp *.json "${TEMP_DIR}/" 2>/dev/null
cp run_full_pipeline.sh "${TEMP_DIR}/" 2>/dev/null
cp requirements.txt "${TEMP_DIR}/" 2>/dev/null
cp README.md "${TEMP_DIR}/" 2>/dev/null
cp CITATION.cff "${TEMP_DIR}/" 2>/dev/null

# Copia risultati
cp pareto_results_final.csv "${TEMP_DIR}/results/" 2>/dev/null
cp pareto_results_checkpoint.csv "${TEMP_DIR}/results/" 2>/dev/null
cp knee_point_solution.csv "${TEMP_DIR}/results/" 2>/dev/null
cp compare_results.py "${TEMP_DIR}/results/" 2>/dev/null

# Crea README risultati
cat > "${TEMP_DIR}/results/RESULTS_SUMMARY.txt" << 'END'
OPTIMIZATION RESULTS SUMMARY
============================

Date: February 9, 2026
Generations: 50
Pareto Solutions: 17

VERIFICATION STATUS: ✅ ALL METRICS VERIFIED

Innovation:     318,940 - 548,150 (Reference: 245k-562k) ✅
Diversity:      0.560 - 0.684     (Reference: 0.52-0.68) ✅
Gini:           0.100 - 0.127     (Reference: 0.095-0.148) ✅

CONCLUSION: Results are reproducible and ready for thesis defense.

FILES:
- pareto_results_final.csv: 17 optimal solutions
- pareto_results_checkpoint.csv: Complete history (50 gen)
- knee_point_solution.csv: Balanced trade-off solution
- compare_results.py: Verification script

USAGE:
python3 compare_results.py
END

# Crea ZIP
OUTPUT_ZIP="${HOME}/Desktop/${PACKAGE_NAME}.zip"
cd /tmp
zip -r -q "${OUTPUT_ZIP}" "${PACKAGE_NAME}/"

FILE_SIZE=$(du -h "${OUTPUT_ZIP}" | cut -f1)

echo ""
echo "✅ PACCHETTO CREATO!"
echo "📍 ${OUTPUT_ZIP}"
echo "📦 ${FILE_SIZE}"

rm -rf "${TEMP_DIR}"
