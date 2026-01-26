Cultural Diversity, Network Dynamics, and Urban Innovation (ABM)

[![NetLogo](https://img.shields.io/badge/Platform-NetLogo-blue.svg)](https://ccl.northwestern.edu/netlogo/)
[![Python](https://img.shields.io/badge/Optimization-Python%20%7C%20pymoo-yellow.svg)](https://pymoo.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

📖 Overview

This repository contains the source code, data, and documentation for the Agent-Based Model (ABM) developed as part of the Doctoral Thesis: "Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes".

The project investigates the nonlinear, coevolutionary dynamics among cultural diversity, social networks, and urban innovation. It challenges traditional notions, often treated as a zero-sum game between economic efficiency and social equity, by proposing a new theoretical state termed the Evolutionary Urban Cultural Complex (EUCC).

---

⚙️ Key Features

The model follows the ODD+D protocol (Overview, Design concepts, Details + Decision-making) and simulates a complex urban system comprising:

1.  Heterogeneous Agents
   Firms, Households, Institutions, and Universities.

2.  Network Dynamics
    Social Networks: Modeled using the Kleinberg Small-World algorithm to simulate local clustering and weak ties.
    Economic Networks: Modeled using Barabási-Albert Scale-Free* preferential attachment to simulate innovation hubs.
    Knowledge Networks: Connecting universities to firms through firms' "bridging capital". These connections simulate knowledge spillover from academic research to the productive sector.

4.  Economic Engine
   A Leontief Input-Output model, integrated with a Knowledge Production Function (KPF) that accounts for cultural diversity and R&D spillovers.

5.  Multi-Objective Optimization
    Implementation of the NSGA-II (Non-dominated Sorting Genetic Algorithm II) to identify Pareto-optimal policy configurations for innovation, diversity, and equality.

---

💻 Installation & Prerequisites

To replicate the simulations or run the optimization, you will need the following software:

1. Agent-Based Simulation
NetLogo 6.3.0+: Download from [Northwestern CCL](https://ccl.northwestern.edu/netlogo/).
Required Extensions (included with standard NetLogo installation):
  `nw` (Network extension)
  `matrix`
  `csv`

2. Evolutionary Optimization (Python)
Python 3.9+
Libraries: `pymoo`, `numpy`, `pandas`, `pynetlogo` (installed via requirements).

3. Setup Instructions

1.  Clone the repository:
    ```bash
    git clone [https://github.com/giambroneannalisa/urban-innovation-abm.git](https://github.com/giambroneannalisa/urban-innovation-abm.git)
    cd urban-innovation-abm
    ```

2.  Create a virtual environment:
    ```bash
    # MacOS / Linux
    python3 -m venv venv
    source venv/bin/activate

    # Windows
    python -m venv venv
    .\venv\Scripts\activate
    ```

3.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```

---

⚠️ Configuration (Crucial Step)

The optimization script runs NetLogo in headless mode. You must configure the path to your local NetLogo installation before running the script.

1.  Open the file `nsga2_config_final.json`.
2.  Locate the `"NETLOGO_PATH"` line.
3.  Change the path to match where NetLogo is installed on your computer.

Examples:
MacOS: `"/Applications/NetLogo 6.3.0/netlogo-headless.sh"`
Windows: `"C:\\Program Files\\NetLogo 6.3.0\\netlogo-headless.bat"`

> Note: On MacOS/Linux, ensure the script is executable: `chmod +x path/to/netlogo-headless.sh`

---

🚀 Usage

Option A: Interactive Simulation (GUI)
Use this mode to visualize the agents and network dynamics in real-time.

1.  Open `Urban_Innovation_Model_vFinal_english.nlogo` in NetLogo.
2.  Click Setup to initialize agents, networks, and the Leontief matrix.
3.  Click Go to run the simulation.
4.  Adjust sliders (e.g., `innovation-diffusion-rate`) to test different scenarios.

Option B: Multi-Objective Optimization (Headless)
Use this mode to find optimal policies using the Genetic Algorithm (NSGA-II).

```bash
# Ensure your virtual environment is active
python nsga2_optimization.py nsga2_config_final.json
