# Urban Innovation ABM - Multi-Objective Optimization Analysis

## 📋 Project Overview

This repository contains the analysis code and results for a PhD thesis on urban innovation dynamics using Agent-Based Modeling (ABM) and Multi-Objective Optimization. The project explores the trade-offs between **innovation output**, **cultural diversity**, and **economic equality** in urban systems.

### Research Questions
- How do policy parameters affect urban innovation ecosystems?
- What is the optimal balance between innovation, diversity, and equality?
- How does bridging social capital influence these outcomes?

---

## 📂 Repository Structure

```plaintext
urban-innovation-abm/
├── README.md                                    # This file
├── complete_thesis_analysis.py                  # Main comprehensive analysis
├── thesis_analysis.py                           # Clustering and archetypes analysis
├── find_knee_point.py                           # Knee point identification
├── plot_bridging_effect.py                      # Bridging capital visualization
├── plot_convergence.py                          # Evolutionary convergence analysis
├── analyze_knee_point.py                        # Detailed knee point analysis
├── pareto_results_final (3).csv                 # Final Pareto optimal solutions
├── pareto_results_checkpoint_FIXED.csv          # Evolution checkpoint data
├── thesis_plots/                                # Generated visualizations
│   ├── Fig1_EUCC_3D_Pareto.png
│   ├── Fig2_Trade_off_Curves.png
│   ├── Fig3_Bridging_Capital_Effects.png
│   ├── Fig4_Radar_Policy_Regimes.png
│   ├── Fig5_Bridging_Panel.png
│   ├── Fig6_Knee_Point.png
│   └── FigA_Convergence_History.png
└── final_results/                               # Final outputs for thesis defense
    ├── EUCC_knee_point_solution.csv
    ├── pareto_results_ranked.csv
    └── summary_statistics.csv
```

---

## 🔧 Scripts Documentation

### 1. **complete_thesis_analysis.py** (Main Analysis)
**Purpose**: Comprehensive Pareto front analysis with knee point identification

**Key Features**:
- Loads and preprocesses Pareto optimization results
- Identifies knee point using Euclidean distance to utopian point
- Alternative knee point method using curvature analysis
- Generates 4 publication-ready figures
- Exports ranked solutions and statistics

**Outputs**:
- `Fig1_EUCC_3D_Pareto.png` - 3D Pareto front with knee point
- `Fig2_Trade_off_Curves.png` - Pairwise objective trade-offs
- `Fig3_Bridging_Capital_Effects.png` - Parameter sensitivity analysis
- `Fig4_Radar_Policy_Regimes.png` - Policy regime comparison
- `EUCC_knee_point_solution.csv` - Optimal compromise solution
- `pareto_results_ranked.csv` - All solutions ranked by distance to utopia

**Usage**:
```bash
python complete_thesis_analysis.py
```

**Key Findings**:
- Knee point achieves 95.8% of maximum innovation
- With 12.7% reduction in inequality vs. max innovation solution
- Optimal cultural diffusion is 3.9x the bridging capital weight

---

### 2. **thesis_analysis.py** (Clustering Analysis)
**Purpose**: K-Means clustering to identify urban policy archetypes

**Key Features**:
- 4-cluster analysis of Pareto solutions
- Automatic archetype naming (Innovation Hub, Equitable City, etc.)
- Correlation analysis between parameters and objectives
- Trade-off quantification

**Outputs**:
- `Fig1_Pareto_Front_Overview.png` - Clustered solutions across 3 views
- `Fig2_Correlation_Heatmap.png` - Parameter-objective correlations
- `Fig3_Parallel_Coordinates.html` - Interactive exploration (requires Plotly)
- `pareto_results_analyzed.csv` - Solutions with cluster assignments

**Identified Archetypes**:
1. 🔴 **Innovation Hub** - Maximum innovation, moderate inequality
2. 🟢 **Equitable City** - Lowest Gini, reduced innovation
3. 🟡 **Diverse Metropolis** - Highest diversity, fragmentation effects
4. 🔵 **Balanced City** - Compromise across all objectives

**Usage**:
```bash
python thesis_analysis.py
```

---

### 3. **find_knee_point.py** (Quick Knee Point)
**Purpose**: Fast knee point identification and visualization

**Key Features**:
- Normalized Euclidean distance to ideal point [1,1,1]
- 3-panel visualization (2D, 3D, ranking)
- Exports single optimal solution

**Outputs**:
- `Fig6_Knee_Point.png` - Knee point identification plots
- `knee_point_solution.csv` - Single optimal parameter set

**Usage**:
```bash
python find_knee_point.py
```

---

### 4. **plot_bridging_effect.py** (Bridging Capital Analysis)
**Purpose**: Analyze the effect of bridging social capital on all objectives

**Key Features**:
- 3D scatter with diversity color mapping
- Regression curves (polynomial order 2)
- Publication-ready styling

**Outputs**:
- `Fig4_Bridging_Tradeoff.png` - 3D bridging capital effects
- `Fig5_Bridging_Panel.png` - 3-panel regression analysis

**Usage**:
```bash
python plot_bridging_effect.py
```

**Key Insight**: Bridging capital has a **non-linear** relationship with innovation (inverted-U shape)

---

### 5. **plot_convergence.py** (Evolutionary Analysis)
**Purpose**: Visualize NSGA-II convergence across 35 generations

**Key Features**:
- Tracks best solutions over evolutionary time
- Shows objective improvement trajectories
- Identifies convergence point

**Outputs**:
- `FigA_Convergence_History.png` - 3-panel convergence plot

**Usage**:
```bash
python plot_convergence.py
```

**Result**: Algorithm converged by generation ~25 (out of 35)

---

### 6. **analyze_knee_point.py** (Detailed Knee Analysis)
**Purpose**: Extended analysis of the knee point solution

**Key Features**:
- 3D Pareto front with highlighted knee point
- Professional camera angles
- PDF and PNG export for thesis

**Outputs**:
- `FigB_3D_Pareto_Front.pdf` - High-resolution 3D plot
- Terminal output with optimal parameter values

**Usage**:
```bash
python analyze_knee_point.py
```

---

## 📊 Key Results Summary

### Optimal Knee Point Solution
**Parameters**:
- Bridging Capital Weight: **0.1878**
- Innovation Diffusion Rate: **0.0788**
- Policy Effectiveness: **0.1754**
- Cultural Diffusion Rate: **0.4218**

**Outcomes**:
- Innovation Output: **446,136 units**
- Cultural Diversity: **0.6390** (Shannon Index)
- Gini Coefficient: **0.1095** (exceptionally low inequality)

### Trade-off Quantification
- **Cost of Equality**: Reducing Gini from 0.1234 to 0.0997 costs 15.2% of innovation
- **Diversity Paradox**: Maximum diversity (0.6826) associated with moderate innovation (fragmentation effects)
- **Optimal Window**: Cultural diversity between 0.57-0.68 maximizes innovation per capita

---

## 🔬 Methodology

### Multi-Objective Optimization
- **Algorithm**: NSGA-II (Non-dominated Sorting Genetic Algorithm II)
- **Objectives**: Maximize Innovation, Maximize Diversity, Minimize Gini
- **Population Size**: 50
- **Generations**: 35
- **Final Pareto Set**: 24 non-dominated solutions

### Knee Point Identification
**Method 1**: Euclidean distance to utopian point [1,1,1] in normalized space
**Method 2**: Maximum curvature detection on Innovation-Gini trade-off

Both methods converged to the same solution (Index 1 in dataset)

---

## 📦 Dependencies

```bash
pip install pandas numpy matplotlib seaborn scipy scikit-learn plotly
```

**Required Python Version**: 3.8+

---

## 🚀 Quick Start

1. **Clone the repository**:
```bash
git clone https://github.com/giambroneannalisa/urban-innovation-abm.git
cd urban-innovation-abm
```

2. **Install dependencies**:
```bash
pip install -r requirements.txt
```

3. **Run the main analysis**:
```bash
python complete_thesis_analysis.py
```

4. **Generate all figures**:
```bash
python thesis_analysis.py
python find_knee_point.py
python plot_bridging_effect.py
python plot_convergence.py
python analyze_knee_point.py
```

All outputs will be saved to `thesis_plots/` and `final_results/`

---

## 📝 Citation

If you use this code or methodology in your research, please cite:

```
[Author Name]. (2024). Urban Innovation Dynamics: A Multi-Objective 
Optimization Approach Using Agent-Based Modeling. [PhD Thesis]. 
[University Name].
```

---

## 📧 Contact

**Author**: Annalisa Giambrone  
**Email**: [your.email@university.edu]  
**GitHub**: [@giambroneannalisa](https://github.com/giambroneannalisa)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- NSGA-II algorithm implementation based on [cite library]
- Visualization inspired by urban systems complexity research
- Thesis supervised by [Advisor Name]

---

**Last Updated**: February 2026  
**Status**: ✅ Final Analysis Complete - Ready for Thesis Defense