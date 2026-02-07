import json
import os
import subprocess
import sys
import pandas as pd
import numpy as np
import multiprocessing
from functools import partial

from pymoo.core.problem import ElementwiseProblem
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize
from pymoo.operators.sampling.rnd import FloatRandomSampling
from pymoo.operators.crossover.sbx import SBX
from pymoo.operators.mutation.pm import PM
from pymoo.core.callback import Callback

# --- XML TEMPLATE CONFIGURATION ---
# Added {seed} to the template to ensure reproducibility
EXPERIMENT_XML = """
<experiments>
  <experiment name="optimization_run" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="{ticks}"/>
    <metric>total-innovation-output</metric>
    <metric>cultural-diversity-index</metric>
    <metric>gini-coefficient</metric>
    <enumeratedValueSet variable="random-seed">
      <value value="{seed}"/>
    </enumeratedValueSet>
    {enumerated_values}
  </experiment>
</experiments>
"""

class CheckpointCallback(Callback):
    def __init__(self, param_names):
        super().__init__()
        self.param_names = param_names
        self.filename = "pareto_results_checkpoint.csv"
        if not os.path.exists(self.filename):
            # Added "Seeds" to the checkpoint columns
            cols = ["Generation"] + param_names + ["Obj_Innov_Neg", "Obj_Div_Neg", "Obj_Gini"]
            pd.DataFrame(columns=cols).to_csv(self.filename, index=False)
            print(f"💾 Checkpoint file created: {self.filename}")

    def notify(self, algorithm):
        gen = algorithm.n_gen
        pop = algorithm.pop
        X = pop.get("X")
        F = pop.get("F")
        df = pd.DataFrame(X, columns=self.param_names)
        df['Obj_Innov_Neg'] = F[:, 0]
        df['Obj_Div_Neg'] = F[:, 1]
        df['Obj_Gini'] = F[:, 2]
        df['Generation'] = gen
        df.to_csv(self.filename, mode='a', header=False, index=False)
        print(f"✅ Data saved for Generation {gen}")

# --- PARALLEL SIMULATION HELPER ---
def run_single_simulation(params, config, replicate_id):
    pid = os.getpid()
    unique_id = f"{pid}_{replicate_id}_{np.random.randint(1000, 9999)}"
    
    # GENERATING THE RANDOM SEED
    current_seed = int(np.random.randint(0, 2147483647))
    
    param_xml_lines = ""
    for key, val in params.items():
        param_xml_lines += f'<enumeratedValueSet variable="{key}"><value value="{val}"/></enumeratedValueSet>\n'
    
    # Passing the seed to the XML content
    xml_content = EXPERIMENT_XML.format(
        ticks=config["MAX_TICKS"],
        seed=current_seed,
        enumerated_values=param_xml_lines
    )
    
    xml_filename = f"temp_{unique_id}.xml"
    csv_filename = f"temp_{unique_id}.csv"
    
    try:
        with open(xml_filename, "w") as f:
            f.write(xml_content)

        cmd = [
            config["NETLOGO_PATH"],
            "--headless",
            "--model", config["MODEL_PATH"],
            "--setup-file", xml_filename,
            "--table", csv_filename
        ]
        
        # 5-minute timeout to prevent hanging
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True, timeout=300)
        
        try:
            df = pd.read_csv(csv_filename, skiprows=6, on_bad_lines='skip')
        except:
            return None

        if df.empty: return None

        clean_cols = {c: c.replace('"', '').strip() for c in df.columns}
        df.rename(columns=clean_cols, inplace=True)
        final_state = df.iloc[-1]
        
        return {
            'innovation': float(final_state.get('total-innovation-output', 0)),
            'diversity': float(final_state.get('cultural-diversity-index', 0)),
            'gini': float(final_state.get('gini-coefficient', 0)),
            'seed': current_seed # Returning the seed for tracking
        }
    except Exception:
        return None
    finally:
        if os.path.exists(xml_filename): os.remove(xml_filename)
        if os.path.exists(csv_filename): os.remove(csv_filename)

class NetLogoOptimization(ElementwiseProblem):
    def __init__(self, config, n_threads=4):
        self.config = config
        self.params = config["PARAM_BOUNDS"]
        self.param_names = list(self.params.keys())
        self.n_replicates = config.get("N_REPLICATES", 1)
        self.n_threads = n_threads
        
        xl = [self.params[k][0] for k in self.param_names]
        xu = [self.params[k][1] for k in self.param_names]
        super().__init__(n_var=len(self.param_names), n_obj=3, xl=xl, xu=xu)

    def _evaluate(self, x, out, *args, **kwargs):
        param_dict = dict(zip(self.param_names, x))
        
        # Parallel execution across replicates
        with multiprocessing.Pool(self.n_threads) as pool:
            func = partial(run_single_simulation, param_dict, self.config)
            results = pool.map(func, range(self.n_replicates))
        
        valid_results = [r for r in results if r is not None]
        
        if not valid_results:
            out["F"] = [1e10, 1e10, 1e10]
            return

        df_res = pd.DataFrame(valid_results)
        avg_innov = df_res['innovation'].mean()
        avg_div = df_res['diversity'].mean()
        avg_gini = df_res['gini'].mean()

        # Save specific seeds used in this evaluation if needed
        # (History can be added here)

        out["F"] = [-avg_innov, -avg_div, avg_gini]
        print(f"   Evaluation: Innovation~{int(avg_innov)} Diversity~{avg_div:.2f} Gini~{avg_gini:.2f}")

if __name__ == "__main__":
    multiprocessing.set_start_method('spawn', force=True)
    
    if len(sys.argv) < 2:
        print("Usage: python3 nsga2_optimization.py nsga2_config_final.json")
        sys.exit(1)

    with open(sys.argv[1], 'r') as f:
        config = json.load(f)

    n_cpu = multiprocessing.cpu_count()
    print(f"--- Starting PARALLEL Optimization (CPUs: {n_cpu}) ---")
    
    problem = NetLogoOptimization(config, n_threads=n_cpu)
    checkpoint_callback = CheckpointCallback(problem.param_names)
    
    algorithm = NSGA2(
        pop_size=config.get("POP_SIZE", 50),
        n_offsprings=10,
        sampling=FloatRandomSampling(),
        crossover=SBX(prob=0.9, eta=15),
        mutation=PM(eta=20),
        eliminate_duplicates=True
    )

    res = minimize(problem,
                   algorithm,
                   ('n_gen', config.get("N_GENERATIONS", 50)),
                   seed=1,
                   callback=checkpoint_callback,
                   verbose=True)

    print("\n--- Optimization Complete ---")
    result_df = pd.DataFrame(res.X, columns=problem.param_names)
    result_df['Obj_Innov_Neg'] = res.F[:, 0]
    result_df['Obj_Div_Neg'] = res.F[:, 1]
    result_df['Obj_Gini'] = res.F[:, 2]
    result_df.to_csv("pareto_results_final.csv", index=False)
    print("Final results saved with success.")
