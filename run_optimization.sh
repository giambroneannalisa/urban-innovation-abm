cat << 'EOF' > run.sh
#!/bin/bash

# Formatting colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Initializing NSGA-II Optimization...${NC}"

# 1. Virtual Environment Setup
if [ ! -d "venv" ]; then
    echo -e "${GREEN}📦 Creating Python virtual environment...${NC}"
    python3 -m venv venv
fi

# 2. Activate and Install Dependencies
source venv/bin/activate
echo -e "${GREEN}📥 Installing/Updating dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

# 3. Execute Simulation
echo -e "${BLUE}🧠 Launching PyMOO Optimization...${NC}"
echo "--------------------------------------------------"
python3 nsga2_optimization.py config.json

# 4. Cleanup
deactivate
echo "--------------------------------------------------"
echo -e "${GREEN}✅ Optimization complete.${NC}"
EOF
chmod +x run.sh
./run.sh
cat << 'EOF' > requirements.txt
pymoo
numpy
pandas
matplotlib
seaborn
alive-progress
scipy
jpype1
pynetlogo
EOF
cat << 'EOF' > config.json
{
    "NETLOGO_PATH": "/Applications/NetLogo 6.3.0/netlogo-headless.sh",
    "MODEL_PATH": "Urban_Innovation_Model_vFinal_english.nlogo",
    "N_REPLICATES": 5,
    "MAX_TICKS": 300,
    "POP_SIZE": 50,
    "N_GENERATIONS": 50,
    "PARAM_BOUNDS": {
        "bridging-capital-weight": [0.0, 1.0],
        "innovation-diffusion-rate": [0.0, 0.2],
        "policy-effectiveness": [0.0, 1.0],
        "cultural-diffusion-rate": [0.0, 0.5]
    }
}
EOF
./run.sh
