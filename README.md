Cultural Diversity, Network Dynamics, and Urban Innovation (ABM)

[![NetLogo](https://img.shields.io/badge/Platform-NetLogo-blue.svg)](https://ccl.northwestern.edu/netlogo/)
[![Python](https://img.shields.io/badge/Optimization-Python%20%7C%20pymoo-yellow.svg)](https://pymoo.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Thesis%20Complete-green.svg)](#)

⚠️ Project Status

This repository contains the complete source code for a Doctoral Thesis. The thesis defense is scheduled for 2026.

---

📖 Overview

This repository hosts the Agent-Based Model (ABM) and multi-objective optimization suite for the research:

"Cultural Diversity, Network Dynamics, and Urban Innovation: An Agent-Based Model of Co-Evolutionary Processes"

The study explores how cultural diversity interacts with urban innovation systems, proposing the Evolutionary Urban Cultural Complex (EUCC) framework to identify policies that balance economic efficiency with social equity.

---

🎓 Academic Affiliation

- PhD Candidate**: Annalisa Giambrone
- Supervisor**: Prof. Raffaele Scuderi
- Institution**: University of Enna "Kore"
- Doctoral Program**: Research Doctorate in "Economic, Business and Legal Sciences"
- Cycle: XXXVIII (Academic Year 2022-2023)

---

⚙️ Methodology

The model follows the ODD+D protocol** (Overview, Design concepts, Details + Decision-making). Complete documentation is available in the thesis.

Key Components

1. Multilayer Networks: Social (Small-World) and Economic (Scale-Free) topologies
2. Economic Engine: Hybrid Leontief Input-Output model + Knowledge Production Function (KPF)
3. Optimization: Policy search using NSGA-II via the `pymoo` library

---

🚀 Quick Start

Prerequisites

- Python 3.8+
- NetLogo 6.3.0+ ([Download here](https://ccl.northwestern.edu/netlogo/download.shtml))
- macOS (tested) or Linux

Installation & Execution

Option 1: Automated Full Pipeline (Recommended)

```bash
Clone the repository
git clone https://github.com/giambroneannalisa/urban-innovation-abm.git
cd urban-innovation-abm

Make the script executable and run
chmod +x run_full_pipeline.sh
./run_full_pipeline.sh
```

Option 2: Manual Setup

```bash
# Clone repository
git clone https://github.com/giambroneannalisa/urban-innovation-abm.git
cd urban-innovation-abm

# Install dependencies
pip install -r requirements.txt

# Run optimization
python3 nsga2_optimization.py nsga2_config_final.json
```

Expected runtime: 4-8 hours (50 generations, 50 population size)

---

📁 Repository Structure

```
urban-innovation-abm/
├── README.md                                 # This file
├── Urban_Innovation_Model_vFinal_english.nlogo  # NetLogo ABM model
├── nsga2_optimization.py                    # NSGA-II optimization script
├── nsga2_config_final.json                  # Optimization parameters
├── requirements.txt                          # Python dependencies
├── run_full_pipeline.sh                     # Automated execution script
└── .gitignore                               # Git ignore rules
```

---

🔍 Reproducibility & Open Science

This project follows the **STROBE-ABM** (Standards for Reporting of Experiments with Agent-Based Models) guidelines.

To Replicate Results

1. Clone the repository** at the thesis defense tag:

```bash
git clone https://github.com/giambroneannalisa/urban-innovation-abm.git
cd urban-innovation-abm
git checkout v1.0-thesis-final
```

2. Run the optimization:

```bash
./run_full_pipeline.sh
```

3. Compare results** with reference outputs:
   - Expected Pareto front: 10-25 solutions
   - Innovation range: 250,000 - 560,000
   - Diversity range: 0.52 - 0.68
   - Gini coefficient: 0.10 - 0.15

Notes on Reproducibility

⚠️ Stochastic Variability: Due to NetLogo's internal randomness and parallel execution, exact numerical results may vary slightly (±5%) between runs. Statistical properties and trade-off patterns remain stable.

For rigorous scientific replication:
1. Run the optimization 3-5 times
2. Report **aggregate statistics** (mean ± std)
3. Compare **Pareto front distributions**

---

📄 Citation

If you use this model or code in your research, please cite:

```bibtex
@phdthesis{giambrone2026urban,
  author    = {Giambrone, Annalisa},
  title     = {Cultural Diversity, Network Dynamics, and Urban Innovation: 
               An Agent-Based Model of Co-Evolutionary Processes},
  school    = {University of Enna "Kore"},
  year      = {2026},
  type      = {PhD Thesis},
  note      = {Cycle XXXVIII},
  url       = {https://github.com/giambroneannalisa/urban-innovation-abm}
}
```

---

📬 Contact

Annalisa Giambrone  
PhD Candidate - University of Enna "Kore"  
📧 Email: giambroneannalisa@gmail.com  
🐙 GitHub: [@giambroneannalisa](https://github.com/giambroneannalisa)

For questions about:
- Replication issues: Open a GitHub issue
- Collaboration: Email with subject "Collaboration - Urban Innovation ABM"
- Citation: See BibTeX entry above

---

🙏 Acknowledgments

This research was conducted under the supervision of Prof. Raffaele Scuderi at the University of Enna "Kore".

---

📊 Key Results (Preliminary)

Based on the optimization runs:

| Metric | Range | Interpretation |
|--------|-------|----------------|
| Innovation | 250k - 560k | Total innovations in system |
| Cultural Diversity | 0.52 - 0.68 | Shannon diversity index |
| Gini Coefficient | 0.10 - 0.15 | Income inequality (lower = better) |

The EUCC framework successfully identifies policy configurations that achieve high innovation while maintaining low inequality.

---

**Repository Tag**: `v1.0-thesis-final`  
**Last Updated**: February 2026  
**Status**: Ready for thesis defense ✅
