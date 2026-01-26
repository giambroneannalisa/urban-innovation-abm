Cultural Diversity, Network Dynamics, and Urban Innovation (ABM)

[![NetLogo](https://img.shields.io/badge/Platform-NetLogo-blue.svg)](https://ccl.northwestern.edu/netlogo/)
[![Python](https://img.shields.io/badge/Optimization-Python%20%7C%20pymoo-yellow.svg)](https://pymoo.org/)


📖 Overview
This repository contains the source code, data, and documentation for the Agent-Based Model (ABM) developed as part of the Doctoral Thesis: "Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes".

The project investigates the non-linear, co-evolutionary dynamics** between cultural diversity, social networks, and urban innovation. It challenges traditional notions, often treated as a zero-sum game between economic efficiency and social equity, by proposing a new theoretical state termed the Evolutionary Urban Cultural Complex (EUCC).

---

⚙️ Key Features
This Agent-Based Model follows the **ODD+D protocol** (Overview, Design concepts, Details + Decision-making) and simulates a complex urban system comprising:

1. Heterogeneous Agents
- **Firms, Households, Institutions, and Universities.**

2. Network Dynamics
- Social Networks:** Modeled using the Kleinberg Small-World algorithm to simulate local clustering and weak ties.
- Economic Networks:** Modeled using Barabási-Albert Scale-Free preferential attachment to simulate innovation hubs.

3. Economic Engine
- A Leontief Input-Output model**, integrated with a **Knowledge Production Function (KPF)** that accounts for cultural diversity and R&D spillovers.

4. Multi-Objective Optimization
- Implementation of the NSGA-II (Non-dominated Sorting Genetic Algorithm II) to identify Pareto-optimal policy configurations for innovation, diversity, and equality.

---

💻 Installation & Prerequisites

To replicate the simulations or run the optimization, you will need the following software:

1. Agent-Based Simulation
- NetLogo 6.x: Download from [Northwestern CCL](https://ccl.northwestern.edu/netlogo/).
- Required Extensions: These come with the standard NetLogo installation:
  - `nw` (Network extension)
  - `matrix`
  - `csv`

2. Evolutionary Optimization
- Python 3.x and the following libraries:
  - `pymoo` (multi-objective optimization)
  - `numpy`, `pandas` (data handling)
  - Other dependencies specified in `requirements.txt`.

---

🚀 Usage

1. Running the Agent-Based Model (GUI)
1. Open the `.nlogo` file in **NetLogo**.
2. Click **Setup** to initialize agents, networks (Small-World/Scale-Free), and the Leontief matrix.
3. Click **Go** to run the simulation.  
   - Time

📖 Overview: 
this repository contains the source code, data, and documentation for the Agent-Based Model (ABM) developed as part of the Doctoral Thesis: "Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes".

The project investigates the non-linear, co-evolutionary dynamics between cultural diversity, social networks, and urban innovation. It challenges the traditional zero-sum game between economic efficiency and social equity, proposing a new theoretical state termed the Evolutionary Urban Cultural Complex (EUCC).

⚙️ Key Features:
the model follows the ODD+D protocol (Overview, Design concepts, Details + Decision-making) and simulates a complex urban system containing:

Heterogeneous Agents: Firms, Households, Institutions, and Universities.
Network Dynamics:
    Social Networks: Modeled using the Kleinberg Small-World algorithm to simulate local clustering and weak ties.
    Economic Networks: Modeled using Barabási-Albert Scale-Free preferential attachment to simulate innovation hubs.
Economic Engine: A Leontief Input-Output model integrated with a Knowledge Production Function (KPF) that accounts for cultural diversity and R&D spillovers.
Multi-Objective Optimization: Implementation of the NSGA-II (Non-dominated Sorting Genetic Algorithm II) to identify Pareto-optimal policy configurations for innovation, diversity, and equality.

💻 Installation & Prerequisites:

to replicate the simulations or run the optimization, you will need the following software:

1. Agent-Based Simulation
NetLogo 6.x: Download from [Northwestern CCL](https://ccl.northwestern.edu/netlogo/).
Required Extensions (included with standard NetLogo installation):
     `nw` (Network extension)
     `matrix`
     `csv`

2. Evolutionary Optimization
Python 3.x
Libraries:
    `pymoo` (Multi-objective optimization)
    `numpy`, `pandas` (Data handling)


📊 Outputs & Metrics:
the model exports data at Micro, Meso, and Macro levels, including
Total Innovation Output: aggregate economic productivity;
Gini Coefficient: a measure of household income inequality;
Shannon Entropy: a measure of cultural diversity;
Segregation Index: physical separation of cultural groups.

📜 Citation:
if you use this model or code in your research, please cite the original Doctoral Thesis: Giambrone, A. (2025). Cultural diversity, network dynamics, and urban innovation: an agent-based model of co-evolutionary processes*. PhD Thesis in Economics, Business and Legal Sciences, Kore University of Enna. Supervisor: Prof. Raffaele Scuderi.

📝 License:
This project is licensed under the MIT License.
