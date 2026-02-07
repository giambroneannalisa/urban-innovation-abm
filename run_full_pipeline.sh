cat << 'EOF' > run_full_pipeline.sh
#!/bin/bash

set -e  # Exit on error

# Formatting colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Urban Innovation ABM - Full Pipeline         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Check if we're inside the project or need to clone
if [ ! -f "nsga2_optimization.py" ]; then
    echo -e "${BLUE}🌐 Cloning Repository from GitHub...${NC}"
    
    if [ -d "urban-innovation-abm" ]; then
        echo -e "${YELLOW}⚠️  Existing directory found. Backing up...${NC}"
        mv urban-innovation-abm "urban-innovation-abm.backup.$(date +%s)"
    fi
    
    git clone https://github.com/giambroneannalisa/urban-innovation-abm.git
    cd urban-innovation-abm || { echo -e "${RED}❌ Error: Clone failed!${NC}"; exit 1; }
else
    echo -e "${GREEN}✓ Already in project directory${NC}"
fi

# Virtual Environment Setup
echo -e "${BLUE}📦 Setting up Python Environment...${NC}"
if [ ! -d "venv" ]; then
    python3 -m venv venv
else
    echo -e "${GREEN}✓ Virtual environment exists${NC}"
fi

source venv/bin/activate
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet

# Config File Check
if [ ! -f "nsga2_config_final.json" ]; then
    echo -e "${YELLOW}⚙️  Creating default configuration file...${NC}"
    cat << 'CONF' > nsga2_config_final.json
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
CONF
else
    echo -e "${GREEN}✓ Using existing configuration${NC}"
fi

# Java Setup for macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v /usr/libexec/java_home &> /dev/null; then
        export JAVA_HOME=$(/usr/libexec/java_home)
        echo -e "${GREEN}✓ Java environment configured${NC}"
    fi
fi

# Run Optimization
echo ""
echo -e "${BLUE}🧠 Launching NSGA-II Optimization...${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
python3 nsga2_optimization.py nsga2_config_final.json

# Cleanup
deactivate

# Summary
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Optimization Complete!${NC}"
echo ""
echo -e "📊 Results saved:"
echo -e "   → pareto_results_final.csv"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
EOF

chmod +x run_full_pipeline.sh
./run_full_pipeline.sh
