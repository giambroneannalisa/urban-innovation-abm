Cultural Diversity, Network Dynamics, and Urban Innovation (ABM)

⚠️ Project Status
This repository is a Work in Progress. It contains the computational framework and source code developed for a forthcoming Doctoral Thesis. The full thesis text, experimental data, and final results are currently under review/embargo until the official defense.

📖 Overview
This repository contains the Agent-Based Model (ABM) and the multi-objective optimization suite for the doctoral research: "Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes".

The study explores the co-evolutionary dynamics between cultural diversity and urban innovation systems, proposing the Evolutionary Urban Cultural Complex (EUCC) as a framework to move beyond the zero-sum game between economic efficiency and social equity.

🎓 Academic Affiliation
PhD Candidate: Annalisa Giambrone
Supervisor: Prof. Raffaele Scuderi
Institution: University of Enna “Kore”
Doctoral Program: Research Doctorate in "Economic, Business and Legal Sciences"
Cycle: XXXVIII Cycle (Academic Year 2022/2023)

⚙️ Key Features & Methodology
The model is built using the ODD+D protocol (Overview, Design concepts, Details + Decision-making). The complete and detailed ODD+D documentation is included in the Appendix of the doctoral thesis.

Multilayer Networks: Integration of Small-World (social) and Scale-Free (economic) topologies.

Economic Engine: A hybrid Leontief Input-Output model coupled with a Knowledge Production Function (KPF).

Optimization: Automated policy search using the NSGA-II (Non-dominated Sorting Genetic Algorithm II) via pymoo.

🚀 Getting Started
1. Configuration
Before running the model, you must configure the environment in nsga2_config_final.json:

Update NETLOGO_PATH to point to your local NetLogo headless script.

Adjust N_REPLICATES and POP_SIZE based on your hardware capabilities.

2. Execution (Automation Script)
To initialize the environment and start the optimization on macOS/Linux:

Bash

chmod +x run.sh
./run.sh
🛠 Troubleshooting (macOS)
Java Virtual Machine: Ensure your JAVA_HOME is correctly exported: export JAVA_HOME=$(/usr/libexec/java_home).

Headless Permissions: If the script fails to launch NetLogo, run: chmod +x "/Applications/NetLogo 6.3.0/netlogo-headless.sh".

Parallel Processing: On Apple Silicon (M1/M2/M3), it is recommended to use Python 3.11 or 3.12 for stable jpype1 performance.

📝 Citation
Please cite this research as follows:

Giambrone, A. (2026). Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes. Doctoral Thesis, XXXVIII Cycle. University of Enna “Kore”. (Forthcoming / Work in Progress). Supervised by Prof. Raffaele Scuderi.

📄 License
The code in this repository is licensed under the MIT License. However, the theoretical framework and the specific EUCC model logic remain the intellectual property of the author as part of the doctoral research.
