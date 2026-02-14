#!/bin/bash

# ============================================================
# Script: Creazione Pacchetto Tesi per Revisione Supervisore
# Autore: Annalisa Giambrone
# Data: 2026-02-09
# ============================================================

set -e  # Exit on error

echo "======================================================"
echo "  Creazione Pacchetto Tesi - Urban Innovation ABM"
echo "======================================================"
echo ""

# Colori per output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Verifica directory corrente
if [ ! -f "nsga2_optimization.py" ]; then
    echo -e "${YELLOW}⚠️  Devi eseguire questo script dalla directory del repository!${NC}"
    echo "Esempio: cd ~/Desktop/urban-innovation-abm"
    exit 1
fi

echo -e "${BLUE}📂 Directory corrente verificata${NC}"

# Step 2: Crea cartella temporanea per il pacchetto
PACKAGE_NAME="urban-innovation-abm-thesis-v1.0"
TEMP_DIR="/tmp/${PACKAGE_NAME}"

echo -e "${BLUE}📦 Creazione struttura pacchetto...${NC}"

# Rimuovi directory temporanea se esiste già
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"

# Step 3: Copia file essenziali
echo -e "${BLUE}📋 Copia file sorgenti...${NC}"

cp Urban_Innovation_Model_vFinal_english.nlogo "${TEMP_DIR}/"
cp nsga2_optimization.py "${TEMP_DIR}/"
cp nsga2_config_final.json "${TEMP_DIR}/"
cp run_full_pipeline.sh "${TEMP_DIR}/"
cp requirements.txt "${TEMP_DIR}/"
cp README.md "${TEMP_DIR}/"

# Copia CITATION.cff se esiste
if [ -f "CITATION.cff" ]; then
    cp CITATION.cff "${TEMP_DIR}/"
fi

# Step 4: Crea README per supervisore
echo -e "${BLUE}📄 Generazione README_FOR_SUPERVISOR.md...${NC}"

cat > "${TEMP_DIR}/README_FOR_SUPERVISOR.md" << 'SUPERVISOR_README'
# Repository Tesi di Dottorato - Annalisa Giambrone

**Gentile Prof. Scuderi**,\

Questo pacchetto contiene il codice completo del modello Agent-Based sviluppato per la mia tesi di dottorato.

---

## 📁 Contenuto del Pacchetto

### File Principali
- **Urban_Innovation_Model_vFinal_english.nlogo** - Modello NetLogo ABM (3,000+ righe)
- **nsga2_optimization.py** - Script di ottimizzazione NSGA-II (Python)
- **nsga2_config_final.json** - Parametri di configurazione
- **run_full_pipeline.sh** - Script di esecuzione automatica

### Documentazione
- **README.md** - Documentazione completa del progetto
- **requirements.txt** - Dipendenze Python
- **CITATION.cff** - Metadati per citazione accademica

---

## 🔍 Revisione Rapida (Solo Lettura)

### Modello NetLogo
1. Scaricare NetLogo 6.3.0: https://ccl.northwestern.edu/netlogo/download.shtml
2. File → Open → `Urban_Innovation_Model_vFinal_english.nlogo`
3. Esplorare le tabs: Interface, Info, Code
4. (Opzionale) Setup → Go per eseguire

### Codice Python
Aprire `nsga2_optimization.py` con qualsiasi editor di testo.

**Struttura chiave**:
- Linee 1-50: Imports e configurazione XML
- Linee 51-120: Callback e gestione checkpoint
- Linee 121-180: Esecuzione parallela simulazioni
- Linee 181-250: Classe problema ottimizzazione
- Linee 251-300: Main loop NSGA-II

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

### Esecuzione Automatica
```bash
chmod +x run_full_pipeline.sh
./run_full_pipeline.sh
```

### Output Atteso
- File generato: `pareto_results_final.csv`
- Numero soluzioni: 15-25
- Tempo stimato: 4-8 ore (dipende da CPU)

---

## 📊 Risultati di Riferimento

### Metriche Attese (dalla tesi)
| Metrica | Minimo | Massimo | Mediana |
|---------|--------|---------|---------|
| Innovazione Totale | 245,000 | 562,000 | 380,000 |
| Diversità Culturale | 0.52 | 0.68 | 0.61 |
| Coefficiente Gini | 0.095 | 0.148 | 0.118 |

### Interpretazione
- **Innovazione**: Output cumulativo del sistema
- **Diversità**: Indice Shannon normalizzato
- **Gini**: Disuguaglianza di reddito (più basso = più equo)

---

## 🔗 Risorse Aggiuntive

### Repository GitHub
https://github.com/giambroneannalisa/urban-innovation-abm
(Attualmente privato - disponibile su richiesta)

### Documentazione Tecnica
- Protocollo ODD+D: Vedere Appendice Tesi
- Parametri modello: `nsga2_config_final.json`
- Metodologia: Capitolo 3 della Tesi

---

## 📧 Contatti

Per domande, chiarimenti o richieste di accesso al repository:

**Annalisa Giambrone**  \nPhD Candidate - Cycle XXXVIII  \nUniversity of Enna "Kore"  \n\n📧 Email: giambroneannalisa@gmail.com  \n🐙 GitHub: @giambroneannalisa  \n\n---

**Data pacchetto**: 9 Febbraio 2026  \n**Versione codice**: 1.0 (Thesis Defense)  \n**Status**: Codice completo e testato ✅
SUPERVISOR_README

# Step 5: Crea file INFO.txt con metadati
cat > "${TEMP_DIR}/INFO.txt" << 'INFO'
=======================================================
  PACCHETTO TESI - URBAN INNOVATION ABM
=======================================================

Autore: Annalisa Giambrone
Supervisore: Prof. Raffaele Scuderi
Istituzione: Università degli Studi di Enna "Kore"
Dottorato: Scienze Economiche, Aziendali e Giuridiche
Ciclo: XXXVIII (A.A. 2022-2023)

Titolo Tesi:
"Cultural Diversity, Network Dynamics, and Urban Innovation: 
An Agent-Based Model of Co-Evolutionary Processes"

Data Pacchetto: 2026-02-09
Versione: 1.0 (Thesis Defense)

=======================================================

CONTENUTO:
- Modello NetLogo ABM completo
- Framework ottimizzazione NSGA-II
- Documentazione tecnica
- Script esecuzione automatica

DIMENSIONI:
- Modello NetLogo: ~3,000 righe di codice
- Script Python: ~300 righe
- File configurazione: JSON

REQUISITI ESECUZIONE:
- NetLogo 6.3.0+
- Python 3.8+
- 8 GB RAM

Per istruzioni dettagliate:
Leggere README_FOR_SUPERVISOR.md

=======================================================
INFO

echo -e "${GREEN}✅ File documentazione creati${NC}"

# Step 6: Rimuovi file temporanei e non necessari
echo -e "${BLUE}🧹 Pulizia file temporanei...${NC}"

# Nessuna pulizia necessaria (cartella temporanea isolata)

# Step 7: Crea archivio ZIP
OUTPUT_ZIP="${HOME}/Desktop/${PACKAGE_NAME}.zip"

echo -e "${BLUE}📦 Creazione archivio ZIP...${NC}"

cd /tmp
zip -r "${OUTPUT_ZIP}" "${PACKAGE_NAME}/" > /dev/null 2>&1

# Step 8: Verifica successo
if [ -f "${OUTPUT_ZIP}" ]; then
    FILE_SIZE=$(du -h "${OUTPUT_ZIP}" | cut -f1)
    echo ""
    echo -e "${GREEN}✅ PACCHETTO CREATO CON SUCCESSO!${NC}"
    echo ""
    echo "📍 Posizione: ${OUTPUT_ZIP}"
    echo "📦 Dimensione: ${FILE_SIZE}"
    echo ""
    echo "========================================================"
    echo "  PROSSIMI PASSI"
    echo "========================================================"
    echo ""
    echo "1. Aprire il file ZIP sul Desktop"
    echo "2. Verificare il contenuto"
    echo "3. Inviare via email al Prof. Scuderi"
    echo ""
    echo "📧 Email suggerita:"
    echo "   Oggetto: Repository Codice Tesi - Revisione"
    echo "   Allegato: ${PACKAGE_NAME}.zip"
    echo ""
    echo "🔗 Repository GitHub (privato):"
    echo "   https://github.com/giambroneannalisa/urban-innovation-abm"
    echo ""
else
    echo -e "${YELLOW}⚠️  Errore nella creazione del pacchetto${NC}"
    exit 1
fi

# Cleanup directory temporanea
rm -rf "${TEMP_DIR}"

echo -e "${GREEN}✨ Operazione completata!${NC}
"