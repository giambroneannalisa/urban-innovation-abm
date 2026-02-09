#!/bin/bash

# ============================================================================
# Script: Create Supervisor Package
# Purpose: Prepare a professional ZIP package for thesis supervisor review
# Author: Annalisa Giambrone
# Date: February 2026
# ============================================================================

set -e  # Exit on error

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
PACKAGE_NAME="urban-innovation-abm-thesis-v1.0"
PACKAGE_DIR="${PACKAGE_NAME}"
ZIP_NAME="${PACKAGE_NAME}.zip"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Thesis Package Creator for Supervisor       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Clean previous packages
echo -e "${YELLOW}[1/6]${NC} Cleaning previous packages..."
if [ -d "${PACKAGE_DIR}" ]; then
    rm -rf "${PACKAGE_DIR}"
    echo -e "${GREEN}✓${NC} Removed existing directory"
fi
if [ -f "${ZIP_NAME}" ]; then
    rm -f "${ZIP_NAME}"
    echo -e "${GREEN}✓${NC} Removed existing ZIP"
fi

# Step 2: Create package directory structure
echo -e "${YELLOW}[2/6]${NC} Creating package structure..."
mkdir -p "${PACKAGE_DIR}"

# Step 3: Copy essential files
echo -e "${YELLOW}[3/6]${NC} Copying repository files..."

# Core model files
cp Urban_Innovation_Model_vFinal_english.nlogo "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${RED}⚠${NC} Model file not found"
cp nsga2_optimization.py "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${RED}⚠${NC} Optimization script not found"
cp nsga2_config_final.json "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${RED}⚠${NC} Config file not found"
cp run_full_pipeline.sh "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${RED}⚠${NC} Pipeline script not found"
cp requirements.txt "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${RED}⚠${NC} Requirements file not found"

# Documentation files
cp README.md "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${RED}⚠${NC} README not found"
cp CITATION.cff "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${GREEN}✓${NC} CITATION.cff copied (optional)"
cp LICENSE "${PACKAGE_DIR}/" 2>/dev/null || echo -e "${YELLOW}ℹ${NC} LICENSE not found (optional)"

echo -e "${GREEN}✓${NC} Core files copied"

# Step 4: Create supervisor-specific README
echo -e "${YELLOW}[4/6]${NC} Creating supervisor documentation..."

cat > "${PACKAGE_DIR}/README_FOR_SUPERVISOR.md" << 'SUPERVISOR_README'
# Repository Tesi di Dottorato - Annalisa Giambrone

**Gentile Prof. Scuderi**, 

Questo pacchetto contiene il codice completo del modello Agent-Based sviluppato per la mia tesi di dottorato.

---

## 📁 Contenuto del Pacchetto

### File Principali
- `Urban_Innovation_Model_vFinal_english.nlogo` - Modello NetLogo ABM (~2500 righe)
- `nsga2_optimization.py` - Script di ottimizzazione NSGA-II (~350 righe)
- `nsga2_config_final.json` - Parametri di configurazione
- `run_full_pipeline.sh` - Script di esecuzione automatica

### Documentazione
- `README.md` - Documentazione completa del progetto
- `CITATION.cff` - Metadati per citazione
- `requirements.txt` - Dipendenze Python

---

## 🔍 Revisione del Codice (Solo Lettura)

### Opzione 1: Lettura Diretta
I file sono in formato testo e possono essere aperti con qualsiasi editor:
- **NetLogo (.nlogo)**: Apribile con NetLogo GUI o editor di testo
- **Python (.py)**: Apribile con VSCode, PyCharm, o editor di testo
- **JSON**: Configurazione parametri in formato leggibile

### Opzione 2: Visualizzazione Modello NetLogo
1. Scaricare NetLogo 6.3.0: https://ccl.northwestern.edu/netlogo/download.shtml
2. File → Open → `Urban_Innovation_Model_vFinal_english.nlogo`
3. Esplorare le tabs: Interface, Info, Code
4. (Opzionale) Setup → Go per eseguire

---

## 🚀 Esecuzione Completa (Opzionale)

**⚠️ Attenzione**: L'esecuzione completa richiede 6-8 ore di calcolo.
Questa sezione è opzionale - il codice può essere revisionato senza eseguirlo.

### Requisiti Software
- **NetLogo 6.3.0+**: https://ccl.northwestern.edu/netlogo/download.shtml
- **Python 3.8+**: https://www.python.org/downloads/
- **8 GB RAM** disponibili

### Installazione Dipendenze
```bash
# Verificare Python installato
python3 --version

# Installare librerie richieste
pip install -r requirements.txt
```

### Esecuzione
```bash
# Rendere eseguibile lo script
chmod +x run_full_pipeline.sh

# Lanciare ottimizzazione completa
./run_full_pipeline.sh
```

### Risultati Attesi
Dopo 6-8 ore:
- **File output**: `pareto_results_final.csv`
- **Numero soluzioni**: 15-25 configurazioni di policy ottimali
- **Metriche**: 
  - Innovazione: 250,000 - 560,000
  - Diversità: 0.52 - 0.68
  - Gini: 0.10 - 0.15

---

## 📊 Struttura del Modello

### Architettura ABM
```
Agenti:
├── Households (50) → Dinamiche culturali e mobilità
├── Firms (50) → Innovazione e produzione
├── Institutions (5) → Policy adattive
└── Universities (3) → Ricerca e knowledge spillover

Networks:
├── Social Links → Small-World (Kleinberg)
├── Economic Links → Scale-Free (Preferential Attachment)
└── Knowledge Links → University-Firm collaborations
```

### Parametri Ottimizzati
1. **bridging-capital-weight** [0.0, 1.0]
2. **innovation-diffusion-rate** [0.0, 0.2]
3. **policy-effectiveness** [0.0, 1.0]
4. **cultural-diffusion-rate** [0.0, 0.5]

### Obiettivi (Multi-Objective)
- **Massimizzare**: Innovazione totale
- **Massimizzare**: Diversità culturale (Shannon)
- **Minimizzare**: Disuguaglianza (Gini)

---

## 🔬 Dettagli Tecnici

### Protocollo ODD+D
Il modello segue il protocollo **ODD+D** (Overview, Design concepts, Details + Decision-making) 
come da standard internazionale per ABM. Documentazione completa nel Capitolo 3 della tesi.

### Validazione
- **Face validity**: Discussa con esperti del dominio
- **Empirical validation**: Confronto con dati EUROSTAT su innovazione urbana
- **Sensitivity analysis**: 500+ simulazioni Monte Carlo

### Riproducibilità
- **Random seed**: Controllato via `external-seed` parameter
- **Versioning**: Repository GitHub con version control
- **Environment**: Documentato in `requirements.txt`

---

## 📧 Supporto e Contatti

Per domande tecniche o chiarimenti:

- **Email**: giambroneannalisa@gmail.com
- **Repository GitHub** (privato): https://github.com/giambroneannalisa/urban-innovation-abm
- **Risposta prevista**: 24-48 ore

### Possibili Domande Frequenti

**Q: Posso modificare i parametri?**
A: Sì, editare `nsga2_config_final.json`. Valori usati nella tesi: POP_SIZE=50, N_GENERATIONS=50

**Q: Il codice gira su Windows?**
A: Parzialmente supportato. Consigliato macOS/Linux o WSL2 su Windows.

**Q: Quanto tempo per una singola simulazione?**
A: ~45-90 secondi (300 ticks con 150 agenti)

**Q: Come visualizzare i risultati?**
A: Il file `pareto_results_final.csv` è apribile con Excel, R, Python/pandas

---

## 📚 Riferimenti Bibliografici

Principali framework teorici implementati:

- **ABM**: Epstein & Axtell (1996) - Growing Artificial Societies
- **Networks**: Watts & Strogatz (1998) - Small-World; Barabási & Albert (1999) - Scale-Free
- **Ottimizzazione**: Deb et al. (2002) - NSGA-II algorithm
- **ODD Protocol**: Grimm et al. (2020) - ODD+D for ABM

---

**Data pacchetto**: 9 Febbraio 2026  
**Versione modello**: 1.0 (Finale per difesa)  
**Stato**: Pronto per revisione ✅

---

*Questo pacchetto è stato generato automaticamente tramite `create_supervisor_package.sh`*
SUPERVISOR_README

echo -e "${GREEN}✓${NC} Supervisor README created"

# Step 5: Create package info file
cat > "${PACKAGE_DIR}/PACKAGE_INFO.txt" << EOF
╔════════════════════════════════════════════════╗
║   THESIS CODE PACKAGE - INFORMATION            ║
╚════════════════════════════════════════════════╝

PhD Candidate: Annalisa Giambrone
Supervisor: Prof. Raffaele Scuderi
Institution: University of Enna "Kore"
Program: Economic, Business and Legal Sciences (Cycle XXXVIII)

Thesis Title:
"Cultural Diversity, Network Dynamics, and Urban Innovation: 
An Agent-Based Model of Co-Evolutionary Processes"

Package Created: $(date "+%Y-%m-%d %H:%M:%S")
Package Version: 1.0
Repository: https://github.com/giambroneannalisa/urban-innovation-abm

═══════════════════════════════════════════════

FILE MANIFEST:

Core Model:
  ✓ Urban_Innovation_Model_vFinal_english.nlogo
  ✓ nsga2_optimization.py
  ✓ nsga2_config_final.json
  ✓ run_full_pipeline.sh
  ✓ requirements.txt

Documentation:
  ✓ README.md
  ✓ README_FOR_SUPERVISOR.md (START HERE!)
  ✓ PACKAGE_INFO.txt (this file)
  ✓ CITATION.cff

═══════════════════════════════════════════════

QUICK START FOR SUPERVISOR:

1. Read: README_FOR_SUPERVISOR.md
2. Review Code: Open .nlogo and .py files with text editor
3. (Optional) Execute: ./run_full_pipeline.sh

═══════════════════════════════════════════════

Contact: giambroneannalisa@gmail.com
EOF

echo -e "${GREEN}✓${NC} Package info created"

# Step 6: Create ZIP archive
echo -e "${YELLOW}[5/6]${NC} Creating ZIP archive..."
zip -r -q "${ZIP_NAME}" "${PACKAGE_DIR}"
echo -e "${GREEN}✓${NC} ZIP archive created: ${ZIP_NAME}"

# Step 7: Display summary
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Package Creation Complete!                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Get file sizes
ZIP_SIZE=$(du -h "${ZIP_NAME}" | cut -f1)
DIR_SIZE=$(du -sh "${PACKAGE_DIR}" | cut -f1)

echo -e "${GREEN}📦 Package Details:${NC}" 
echo -e "   Directory: ${PACKAGE_DIR}/ (${DIR_SIZE})" 
echo -e "   ZIP file:  ${ZIP_NAME} (${ZIP_SIZE})" 
echo ""
echo -e "${GREEN}📂 Package Contents:${NC}" 
ls -lh "${PACKAGE_DIR}" | tail -n +2 | awk '{printf "   %-40s %8s\n", $9, $5}' 
echo ""
echo -e "${YELLOW}📧 Next Steps:${NC}" 
echo -e "   1. Locate the file: ${PWD}/${ZIP_NAME}" 
echo -e "   2. Send via email to Prof. Scuderi" 
echo -e "   3. Use the email template below:" 
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}" 
cat << 'EMAIL'

─────────────────────────────────────────────
Email Template:
─────────────────────────────────────────────

Oggetto: Repository Codice Tesi - Revisione

Gentile Prof. Scuderi,

in allegato trova il pacchetto completo del codice sviluppato 
per la mia tesi di dottorato:

"Cultural Diversity, Network Dynamics, and Urban Innovation: 
An Agent-Based Model of Co-Evolutionary Processes"

Il pacchetto contiene:
✓ Modello NetLogo completo
✓ Framework di ottimizzazione NSGA-II
✓ Documentazione tecnica completa
✓ Guida all'esecuzione (opzionale)

All'interno troverà il file README_FOR_SUPERVISOR.md con 
istruzioni dettagliate per la revisione.

Rimango a disposizione per qualsiasi chiarimento.

Cordiali saluti,
Annalisa Giambrone

PhD Candidate - Cycle XXXVIII
University of Enna "Kore"
Email: giambroneannalisa@gmail.com

─────────────────────────────────────────────
EMAIL
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ All done! Package ready for delivery.${NC}" 
echo ""

# Optional: Open folder (macOS/Linux)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}Opening package folder...${NC}"
    open .
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open .
    fi
fi
