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
# Carica esplicitamente il file nsga2_config_final.json
python3 nsga2_optimization.py nsga2_config_final.json

# 4. Cleanup
deactivate
echo "--------------------------------------------------"
echo -e "${GREEN}✅ Optimization complete.${NC}"
EOF

chmod +x run.sh
