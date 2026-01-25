Cultural Diversity, Network Dynamics, and Urban Innovation (ABM)

[![NetLogo](https://img.shields.io/badge/Platform-NetLogo-blue.svg)](https://ccl.northwestern.edu/netlogo/)
[![Python](https://img.shields.io/badge/Optimization-Python%20%7C%20pymoo-yellow.svg)](https://pymoo.org/)

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

📂 Repository Structure;

the repository is organized to ensure computational transparency and reproducibility:

`/model`: Contains the core NetLogo simulation file (`.nlogo`).
`/optimization`: Contains Python scripts using the `pymoo` framework for the evolutionary optimization process.
    `nsga2_config_full.json`: Configuration file for the optimization experiment.
  `/data`: Output logs and simulation data.
    `households_data.csv`, `firms_data.csv`, `summary_metrics.csv`, `economic_network.csv`.

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

🚀 Usage:

running the Model (GUI)
1.  Open the `.nlogo` file in NetLogo.
2.  Click `setup` to initialize agents, networks (Small-World/Scale-Free), and the Leontief matrix.
3.  Click `go` to run the simulation. Time steps (ticks) represent months.
4.  Adjust sliders to test specific parameters (e.g., `bridging-capital-weight`, `cultural-diffusion-rate`).

running the Optimization (Headless)
The optimization script runs the model through 2,750 evaluations to find the Pareto Front.
1.  Navigate to the `/optimization` directory.
2.  Ensure `nsga2_config_full.json` is configured (Standard: Population=50, Generations=50, Monte Carlo replicates=5).
3.  Run the Python script to execute the NSGA-II algorithm.

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

🙏 Acknowledgments:
Supervisor: Prof. Raffaele Scuderi.
Institution: "Kore" University of Enna, Department of Economic and Legal Sciences.
