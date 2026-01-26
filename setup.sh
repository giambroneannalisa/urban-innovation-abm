#!/bin/bash

# Crea un ambiente virtuale
echo "Creazione dell'ambiente virtuale..."
python3 -m venv venv

# Attiva l'ambiente virtuale
echo "Attivazione dell'ambiente virtuale..."
source venv/bin/activate

# Installazione delle dipendenze
echo "Installazione delle dipendenze dal requirements.txt..."
pip install -r requirements.txt

# Esecuzione dello script principale
echo "Esecuzione del main script nsga2_optimization.py..."
python3 nsga2_optimization.py
