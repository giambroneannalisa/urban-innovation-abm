Cultural Diversity, Network Dynamics, and Urban Innovation (ABM)

[![NetLogo](https://img.shields.io/badge/Platform-NetLogo-blue.svg)](https://ccl.northwestern.edu/netlogo/)
[![Python](https://img.shields.io/badge/Optimization-Python%20%7C%20pymoo-yellow.svg)](https://pymoo.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Work%20in%20Progress-orange.svg)](#-project-status)

⚠️ Project Status
This repository is a Work in Progress. It contains the source code developed for a forthcoming Doctoral Thesis**. The full text, experimental data, and final results are currently under review/embargo until the official defense.

---

📖 Overview
This repository hosts the Agent-Based Model (ABM) and the multi-objective optimization suite for the research: 
"Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes".

The study explores how cultural diversity interacts with urban innovation systems, proposing the Evolutionary Urban Cultural Complex (EUCC) framework to identify policies that balance economic efficiency with social equity.

---

🎓 Academic Affiliation
PhD Candidate: Annalisa Giambrone
Supervisor: Prof. Raffaele Scuderi
Institution: University of Enna “Kore”
Doctoral Program: Research Doctorate in "Economic, Business and Legal Sciences"
Cycle: XXXVIII Cycle (Academic Year 2022/2023)

---

⚙️ Methodology
The model follows the ODD+D protocol (Overview, Design concepts, Details + Decision-making). Complete documentation is available in the Thesis.

1.  Multilayer Networks: Social (Small-World) and Economic (Scale-Free) topologies.
2.  Economic Engine: Hybrid Leontief Input-Output model + Knowledge Production Function (KPF).
3.  Optimization: Policy search using **NSGA-II** via the `pymoo` library.

---

🚀 Automated Execution
To clone the project, set up the environment, and run the optimization automatically on macOS:
```bash
chmod +x run_full_pipeline.sh
./run_full_pipeline.sh
