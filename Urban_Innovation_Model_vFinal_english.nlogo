extensions [matrix nw csv]

; =========================
; GLOBALS (Enhanced)
; =========================
globals [
  adoption-threshold
  adoption-speed-t25
  max-share-innovators
  t10-innovators
  t50-innovators
  early-adoption-cumulative
  early-adoption-slope
  adoption-saturated?
  total-innovation-output
  gini-coefficient
  diversity-shannon
  population-size
  cultural-diffusion-rate
  innovation-diffusion-rate
  policy-effectiveness
  external-seed
  A_matrix
  I_minus_A_inv
  demand_vector
  num-sectors
  segregation-index
  cultural-diversity-index
  initial-cultural-diversity
  knowledge-spillover-radius
  social-network-clustering
  bridging-capital-weight
  innovation-subsidy-focus
  spatial-autocorrelation
  max-cultures
  diversity-distinct
  diversity-distinct-normalized
  diversity-simpson
  policy-innovation-effectiveness
  policy-diversity-effectiveness
  policy-equity-effectiveness
  last-innovation-level
  last-diversity-level
  last-equity-level
  innovation-concentration-index
  cultural-mixing-index
  knowledge-network-efficiency-score
  simulation-duration
  initial-cultures
  mutation-prob
  imitation-prob
  share-innovators
  cross-cultural-link-share
  mean-path-length-firms
  degree-centralization-firms
  gentrification-index
]

breed [households household]
breed [firms firm]
breed [institutions institution]
breed [universities university]

undirected-link-breed [social-links social-link]
undirected-link-breed [economic-links economic-link]
undirected-link-breed [knowledge-links knowledge-link]
undirected-link-breed [policy-links policy-link]

households-own [
  income
  cultural-identity
  bonding-capital
  bridging-capital
  location
  education-level
  cultural-tolerance
  cultural-innovation-tendency
  mobility-frequency
]

firms-own [
  innovation-potential
  sector
  innovation-output
  r_and_d_budget
  human-capital
  cultural-diversity
  network-centrality
  production-efficiency
  subsidy-received
  bridging-capital
  learning-curve-factor
  knowledge-absorption-capacity
  strategic-RD-adjustment

  ;; Innovation flags (firms only)
  innovator?
  adopted?
  innovation-score
]

institutions-own [
  policy-budget
  policy-focus
  policy-performance-history
  budget-allocation-strategy
]

universities-own [
  research-budget
  knowledge-stock
  research-focus
  collaboration-intensity
]

patches-own [
  housing-cost
  cultural-composition
  desirability
  neighborhood-diversity
  economic-activity
]

; =========================
; WEIGHTED SELECTION PROCEDURES
; =========================
to-report weighted-one-of [agentset weight-reporter]
  if not any? agentset [ report nobody ]
  let agent-list sort agentset
  let weights map weight-reporter agent-list
  let total-weight sum weights
  if total-weight = 0 [ report one-of agentset ]
  let pick random-float total-weight
  let running-sum 0
  foreach agent-list [
    current-agent ->
    set running-sum running-sum + (runresult weight-reporter current-agent)
    if running-sum > pick [ report current-agent ]
  ]
  report last agent-list
end

to-report weighted-n-of [ n agents weight-fn ]
  if n <= 0 [ report no-turtles ]
  if not any? agents [ report no-turtles ]
  if n >= count agents [ report agents ]
  let result no-turtles
  let candidate-list sort agents
  repeat min list n (length candidate-list) [
    let weights map weight-fn candidate-list
    let total-weight sum weights
    ifelse total-weight > 0 [
      let r random-float total-weight
      let acc 0
      let idx 0
      let picked nobody
      while [idx < length candidate-list and picked = nobody] [
        set acc acc + (item idx weights)
        if acc > r [ set picked item idx candidate-list ]
        set idx idx + 1
      ]
      if picked = nobody [ set picked last candidate-list ]
      set result (turtle-set result picked)
      set candidate-list remove picked candidate-list
    ] [
      let idx random (length candidate-list)
      let picked item idx candidate-list
      set result (turtle-set result picked)
      set candidate-list remove-item idx candidate-list
    ]
  ]
  report result
end

to-report poisson [lambda]
  if lambda <= 0 [ report 0 ]
  let L exp (- lambda)
  let k 0
  let p 1
  while [p > L] [
    set k k + 1
    set p p * random-float 1
  ]
  report k - 1
end

; =========================
; SETUP
; =========================
to-report safe-ln [x]
  report ln (1 + max list 0 x)
end

to-report poisson-approx [lambda]
  if lambda <= 0 [ report 0 ]
  let L exp (- lambda)
  let k 0
  let p 1.0
  while [p > L] [
    set k k + 1
    set p p * random-float 1.0
  ]
  report (k - 1)
end

to update-global-gini
  if any? households [
    set gini-coefficient calculate-gini-coefficient [income] of households
  ]
end

;; --- Gini Helper Injected ---
to-report calculate-gini-coefficient [vals]
  if empty? vals [ report 0 ]
  let sorted-vals sort vals
  let n length sorted-vals
  let sum-vals sum sorted-vals
  if sum-vals = 0 [ report 0 ]
  let numerator 0
  let i 1
  foreach sorted-vals [ v ->
    set numerator numerator + (i * v)
    set i i + 1
  ]
  report (2 * numerator) / (n * sum-vals) - (n + 1) / n
end
;; ----------------------------

to setup
  ;; === SAVE SEED BEFORE CLEAR-ALL ===
  let saved-seed external-seed

  clear-all

  ;; === INITIALIZE EXTERNAL-SEED AS GLOBAL ===
  set external-seed saved-seed

  ;; === PARAMETER GUARDS ===
  if not is-number? bridging-capital-weight     [ set bridging-capital-weight 0.5 ]
  if not is-number? cultural-diffusion-rate     [ set cultural-diffusion-rate 0.10 ]
  if not is-number? innovation-diffusion-rate   [ set innovation-diffusion-rate 0.10 ]
  if not is-number? policy-effectiveness        [ set policy-effectiveness 0.10 ]
  if not is-number? knowledge-spillover-radius  [ set knowledge-spillover-radius 3 ]
  if not is-number? mutation-prob               [ set mutation-prob 0.02 ]
  if not is-number? imitation-prob              [ set imitation-prob 0.25 ]
  if not is-number? initial-cultures            [ set initial-cultures 3 ]

  ;; === CHECK MIN/MAX VALUES ===
  set bridging-capital-weight max list 0 (min list 1.0 bridging-capital-weight)
  set cultural-diffusion-rate max list 0 (min list 1.0 cultural-diffusion-rate)
  set innovation-diffusion-rate max list 0 (min list 1.0 innovation-diffusion-rate)
  set policy-effectiveness max list 0 (min list 1.0 policy-effectiveness)
  set mutation-prob max list 0 (min list 1.0 mutation-prob)
  set imitation-prob max list 0 (min list 1.0 imitation-prob)
  set initial-cultures max list 1 initial-cultures

  ;; === CULTURAL PARAMETERS ===
  set max-cultures (max list 2 initial-cultures)

  ;; === RNG SEED ===
  ifelse (is-number? external-seed and external-seed > 0 and external-seed <= 4294967296)
  [
    random-seed external-seed
    print (word "Using external seed: " external-seed)
  ]
  [
    let fallback-seed (random 100000 + 1)
    random-seed fallback-seed
    set external-seed fallback-seed
    print (word "Using fallback random seed: " fallback-seed)
  ]

  ;; === THRESHOLDS & METRICS - ONLY IF DECLARED IN GLOBALS ===
  set adoption-threshold 0.25
  set adoption-speed-t25 -1

  ;; === AGENT & ENVIRONMENT SETUP ===
  setup-patches
  setup-households
  setup-firms
  setup-institutions
  setup-universities
  setup-networks
  setup-input-output-matrix

  ;; === DYNAMIC INITIALIZATIONS ===
  ;; Remove calls to procedures that do not exist:
  ;; reset-adoption-metrics  ;; if it doesn't exist, comment out or remove
  init-firm-innovation-flags
  ;; update-diversity  ;; if it doesn't exist, comment out or remove

  reset-ticks
  print (word "Setup completed: " count firms " firms, " count households " households")
end

to setup-patches
  ask patches [
    set housing-cost random-float 10
    set cultural-composition random-float 1
    set desirability random-float 1
    set neighborhood-diversity random-float 1
    set economic-activity random-float 1
  ]
end

to setup-households
  create-households num-households [
    set income random-normal 50000 15000
    set cultural-identity random max-cultures
    ; set bonding-capital ; COMMENTED: firms do not have bonding-capital random-float 1
    set bridging-capital random-float bridging-capital-weight
    set education-level random 5
    set cultural-tolerance random-float 1
    set cultural-innovation-tendency random-float 0.1
    set mobility-frequency 0.1 + random-float 0.3
    setxy random-xcor random-ycor
  ]
end

to setup-firms
  create-firms num-firms [
    ;; Positioning
    setxy random-xcor random-ycor

    ;; Sector
    set sector random 15

    ;; Human and social capital (Gaussian with cuts to avoid negatives)
    let hc_raw random-normal 0.5 0.2
    set human-capital max list 0 min list 1 hc_raw

    let br_raw random-normal 0.5 0.2
    set bridging-capital max list 0 min list 1 br_raw

    let bo_raw random-normal 0.5 0.2
    ; set bonding-capital ; COMMENTED: firms do not have bonding-capital max list 0 min list 1 bo_raw

    ;; Initial internal diversity (uniform or derived from human capital)
    set cultural-diversity random-float 1

    ;; R&D Budget with guardrails
    let rd_raw random-normal 50000 20000
    set r_and_d_budget clip (max list 100 rd_raw) 0 1e9

    ;; Initial state
    set innovation-output 0
    set network-centrality 0
    set production-efficiency 1.0
    set subsidy-received 0
    set learning-curve-factor 1.0
    set knowledge-absorption-capacity 0.5 + random-float 0.5
    set strategic-RD-adjustment 0.0
    set innovator? false
    set adopted? false
    set innovation-score 0

    ;; Composite innovation potential metric (all normalized)
    ;; Modifiable weighting: human capital (40%), internal diversity (30%), bridging (20%), noise (10%)
    set innovation-potential (
      0.4 * human-capital +
      0.3 * cultural-diversity +
      0.2 * bridging-capital +
      0.1 * random-float 1
    )
  ]
end

to setup-institutions
  create-institutions num-institutions [
    setxy random-xcor random-ycor
    set policy-budget max list 0 (random-normal 100000 20000)
    set policy-focus one-of ["innovation" "equity" "diversity"]
    set policy-performance-history []
    set budget-allocation-strategy "balanced"
    set color blue
    set size 1.5
  ]
end

to setup-universities
  create-universities num-universities [
    setxy random-xcor random-ycor
    set research-budget max list 0 (random-normal 200000 50000)
    set knowledge-stock random 100
    set research-focus one-of ["basic" "applied" "interdisciplinary"]
    set collaboration-intensity random-float 1
    set color violet
    set size 2
  ]
end

; =========================
; ENHANCED MAIN LOOP
; =========================
to go
  ;; 1. Cultural micro-dynamics (households)
  cultural-mutation-step
  cultural-imitation-step

  ;; 2. Update diversity & adoption metrics (once per tick)
  update-diversity
  update-adoption-metrics   ;; handles adoption-speed-t25 internally

  ;; 3. Agent actions
  ask households [ update-household-enhanced ]
  ask firms      [
    set adopted? false    ;; reset per-tick adoption flag before update
    update-firm-enhanced
  ]
  ask institutions [ implement-adaptive-policies ]
  ask universities  [ conduct-research-enhanced ]

  ;; 4. Innovation diffusion (parametric)
  diffuse-innovation

  ;; 5. Cultural diffusion via social links (households)
  ask households [
    if random-float 1 < cultural-diffusion-rate [
      let hh-neighbors [other-end] of my-social-links
      if any? hh-neighbors [
        ;; Example: adopt identity. You can refine rule (e.g., bias).
        let neighbor one-of hh-neighbors
        ;; set cultural-identity [cultural-identity] of neighbor
      ]
    ]
  ]

  ;; 6. Possibly create a bridging social link (low probability)
  maybe-create-bridging-link

  ;; 7. Networks, economic updates, metrics
  update-networks-enhanced
  update-economy-enhanced
  calculate-enhanced-metrics

  ;; 8. Visualization update
  update-visualization

  ;; 9. Periodic policy effectiveness recalibration
  if ticks mod 10 = 0 [
    update-policy-effectiveness
  ]

  ;; 10. Advance time
  tick
end

to diffuse-innovation
  if count firms < 2 [ stop ]

  ;; Parametric probabilities (tunable)
  let econ-spread-prob     (0.02 + innovation-diffusion-rate * 0.25)
  let spatial-spread-prob  (0.01 + bridging-capital-weight * 0.015)

  ;; Dynamic threshold: 60th percentile
  let pot-threshold innovation-potential-quantile 0.60

  ask firms with [innovator?] [
    ;; Link-based diffusion
    let linked-recipients link-neighbors with [
      breed = firms and
      not innovator? and
      innovation-potential > pot-threshold
    ]
    ask linked-recipients with [ random-float 1.0 < econ-spread-prob ] [
      set innovator? true
      set adopted? true
      set innovation-score innovation-score + (random-float 4)
    ]

    ;; Spatial diffusion
    let spatial-recipients other firms in-radius knowledge-spillover-radius with [
      not innovator? and
      innovation-potential > (pot-threshold - 0.05)
    ]
    ask spatial-recipients with [ random-float 1.0 < spatial-spread-prob ] [
      set innovator? true
      set adopted? true
      set innovation-score innovation-score + (random-float 2)
    ]

    ;; Slight damping to avoid runaway
    set innovation-score innovation-score * 0.995
  ]
end

; =========================
; ENHANCED HOUSEHOLD DYNAMICS (weighted selection)
; =========================
to update-household-enhanced
  if random-float 1 < mobility-frequency [
    let my-income income
    let affordable-patches patches with [housing-cost < my-income * 0.3]
    if any? affordable-patches [
      let target min-one-of affordable-patches [
        distance myself +
        (housing-cost / my-income) -
        (cultural-composition / 10) +
        (0.5 * (cultural-distance ([cultural-identity] of myself) (floor (cultural-composition * max-cultures))))
      ]
      move-to target
    ]
  ]

  if random-float 1 < cultural-diffusion-rate [
    let potential-influencers other households in-radius 3 with [
      bridging-capital > 0.5 and
      ((cultural-distance cultural-identity [cultural-identity] of myself) < 0.3)
    ]
    if any? potential-influencers [
      let influencer weighted-one-of potential-influencers [
        [b] -> [bridging-capital] of b * (1 - (cultural-distance cultural-identity [cultural-identity] of b))
      ]
      if influencer != nobody [
        let similarity 1 - (cultural-distance cultural-identity [cultural-identity] of influencer)
        let influence-strength ([bridging-capital] of influencer * similarity)
        if influence-strength > 0.3 [
          set cultural-identity [cultural-identity] of influencer
        ]
      ]
    ]
  ]

  if random-float 1 < cultural-innovation-tendency [
    set cultural-identity random max-cultures
    set cultural-innovation-tendency cultural-innovation-tendency * 0.9
  ]

  if random-float 1 < 0.01 [
    if education-level < 4 [
      set education-level education-level + 1
      set income income * (1 + random-float 0.1)
    ]
  ]
end

to-report safe-div [num denom default]
  if denom = 0 [ report default ]
  report num / denom
end

to-report cultural-distance [id1 id2]
  report safe-div (abs (id1 - id2)) (max list 1 max-cultures) 0
end

; =========================
; ENHANCED FIRM INNOVATION
; =========================
to update-firm-enhanced
  ask firms [
    ;; --- 1. Structural Access Calculation ---
    let institution-weight 0.5
    let university-weight 0.8

    let structural-access (
      (0.4 * bridging-capital) +
      (0.3 * network-centrality) +
      (0.3 * (count link-neighbors with [breed = institutions] * institution-weight +
              count link-neighbors with [breed = universities] * university-weight))
    )

    ;; --- 2. External Knowledge Calculation ---
    let knowledge-pool 0
    let nearby-innovators link-neighbors with [breed = firms]
    if any? nearby-innovators [
      set knowledge-pool sum [ln (1 + innovation-output)] of nearby-innovators
    ]
    let external-knowledge (structural-access * (1 + (knowledge-pool / 10)))

    ;; --- 3. Input Normalization ---
    let norm-RD  ln (max list 2.718 (r_and_d_budget))
    let norm-HC  max list 0.01 human-capital
    let norm-CD  max list 0.01 cultural-diversity
    let norm-EK  max list 0.01 external-knowledge

    ;; --- 4. Endogenous Productivity Factor ---
    let nearby-firms count other firms in-radius 5
    let subsidy-ratio clip (safe-div subsidy-received r_and_d_budget 0) 0 2
    let A_i (0.15 * (1 + 0.2 * subsidy-ratio) * (1 + 0.05 * nearby-firms) * learning-curve-factor)

    ;; --- 5. MULTIPLICATIVE COBB-DOUGLAS ---
    let alpha 0.25
    let beta  0.30
    let gamma 0.35
    let delta 0.10

    let latent-innovation (
      A_i *
      (norm-RD ^ alpha) *
      (norm-HC ^ beta) *
      (norm-CD ^ gamma) *
      (norm-EK ^ delta)
    )

    ;; --- 6. COORDINATION COST ---
    let coordination-cost (cultural-diversity ^ 2) * 0.5
    let net-intensity (latent-innovation / (1 + coordination-cost))

    ;; --- 7. Stochastic Update ---
    let delta-output poisson (net-intensity * 5)

    set innovation-output innovation-output + delta-output
    set innovation-score innovation-score + (delta-output / 100)

    ;; --- 8. Feedback Loop ---
    set learning-curve-factor min list 2.0 (1 + (ln (1 + innovation-output) / 20))

    if ticks mod 20 = 0 and count firms > 1 [
      nw:set-context firms economic-links
      set network-centrality nw:closeness-centrality
    ]
  ]
end

; =========================
; ADAPTIVE POLICY IMPLEMENTATION (weighted selection)
; =========================
to implement-adaptive-policies
  ask institutions [
    if ticks mod 10 = 0 [
      update-institution-performance
    ]

    if random-float 1 < 0.1 [
      let best-focus "innovation"
      let best-score policy-innovation-effectiveness
      if policy-diversity-effectiveness > best-score [
        set best-score policy-diversity-effectiveness
        set best-focus "diversity"
      ]
      if policy-equity-effectiveness > best-score [
        set best-score policy-equity-effectiveness
        set best-focus "equity"
      ]
      if best-focus != policy-focus [
        set policy-focus best-focus
        set color ifelse-value (policy-focus = "innovation") [ blue ] [
          ifelse-value (policy-focus = "diversity") [ green ] [ yellow ]
        ]
        set policy-performance-history lput (list ticks policy-focus) policy-performance-history
      ]
    ]

    if policy-focus = "innovation" [
      if any? firms and policy-budget > 0 [
        let num-target max list 1 (count firms / 5)
        let target-firms weighted-n-of num-target firms [[f] -> [innovation-output] of f]
        if any? target-firms [
          let subsidy-amount min (list 5000 (policy-budget / (count target-firms + 1)))
          ask target-firms [
            set r_and_d_budget clip (r_and_d_budget + subsidy-amount) 0 1e9
            set subsidy-received subsidy-received + subsidy-amount
          ]
          set policy-budget policy-budget - (subsidy-amount * count target-firms)
        ]
      ]
    ]

    if policy-focus = "diversity" [
      let target-firms firms with [cultural-diversity > 0.6 and innovation-output > 0]
      if any? target-firms and policy-budget > 0 [
        let bonus-amount min (list 3000 (policy-budget / (count target-firms + 1)))
        ask target-firms [
          set r_and_d_budget clip (r_and_d_budget + bonus-amount) 0 1e9
          set subsidy-received subsidy-received + bonus-amount
        ]
        set policy-budget policy-budget - (bonus-amount * count target-firms)
      ]
    ]

    if policy-focus = "equity" [
      let target-households households with [income < 40000]
      if any? target-households and policy-budget > 0 [
        let assistance-amount min (list 2000 (policy-budget / (count target-households + 1)))
        ask target-households [
          set income income + assistance-amount
          if random-float 1 < 0.3 [
            set education-level min (list 4 (education-level + 1))
          ]
        ]
        set policy-budget policy-budget - (assistance-amount * count target-households)
      ]
    ]

    if policy-budget < 10000 and ticks mod 50 = 0 [
      set policy-budget policy-budget + random-normal 50000 10000
    ]
  ]
end

to update-institution-performance
  let my-focus policy-focus
  let performance 0
  if my-focus = "innovation" [ set performance policy-innovation-effectiveness ]
  if my-focus = "diversity"  [ set performance policy-diversity-effectiveness ]
  if my-focus = "equity"     [ set performance policy-equity-effectiveness ]
  if performance < 0.5 [ set budget-allocation-strategy "experimental" ]
  if performance > 1.5 [ set budget-allocation-strategy "scale-up" ]
end

to update-policy-effectiveness
  let current-innovation total-innovation-output
  let current-diversity cultural-diversity-index
  let current-equity 1 - gini-coefficient

  if is-number? last-innovation-level and last-innovation-level > 0 [
    set policy-innovation-effectiveness safe-div (current-innovation - last-innovation-level) last-innovation-level 0
  ]
  if is-number? last-diversity-level and last-diversity-level > 0 [
    set policy-diversity-effectiveness safe-div (current-diversity - last-diversity-level) last-diversity-level 0
  ]
  if is-number? last-equity-level and last-equity-level > 0 [
    set policy-equity-effectiveness safe-div (current-equity - last-equity-level) last-equity-level 0
  ]

  set last-innovation-level current-innovation
  set last-diversity-level current-diversity
  set last-equity-level current-equity
end

; =========================
; NETWORK SETUP & DYNAMICS
; =========================
to setup-networks
  ask social-links [ die ]
  ask economic-links [ die ]
  ask knowledge-links [ die ]
  ask policy-links [ die ]

  ;; Social (households) - Kleinberg small-world
  if count households > 1 [
    let grid-size round sqrt count households
    let rows grid-size
    let cols grid-size
    nw:generate-small-world households social-links rows cols 2.0 true
  ]
  ask social-links [
    set color blue
    set thickness 0.1
  ]

  ;; Economic (firms) - preferential attachment
  if count firms > 1 [
    nw:generate-preferential-attachment firms economic-links (count firms) 2
  ]

  ;; University knowledge links (universities -> firms)
  ask universities [
    let potential-firms (firms with [ bridging-capital > 0.5 ])
    if any? potential-firms [
      let num-links (1 + floor (collaboration-intensity * 5))
      let selected-firms weighted-n-of num-links potential-firms [[f] -> [bridging-capital] of f]
      if any? selected-firms [
        create-knowledge-links-with selected-firms
      ]
    ]
  ]
end

to update-networks-enhanced
  ;; Social rewiring (households)
  ask social-links [
    if random-float 1 < 0.1 [
      let node1 end1
      let node2 end2
      die
      ask one-of (list node1 node2) [
        let potential-partners other households with [
          cultural-tolerance > 0.6 and
          ((cultural-distance cultural-identity [cultural-identity] of myself) < 0.4)
        ]
        if any? potential-partners [
          let new-partner weighted-one-of potential-partners [
            [p] -> [cultural-tolerance] of p * (1 - (cultural-distance cultural-identity [cultural-identity] of p))
          ]
          if new-partner != nobody [
            create-social-link-with new-partner
          ]
        ]
      ]
    ]
  ]

  ;; Periodic economic link update and centrality refresh
  if ticks mod 20 = 0 [
    ask economic-links [
      if random-float 1 < 0.05 [
        let firm1 end1
        let firm2 end2
        let avg-innovation ([innovation-output] of firm1 + [innovation-output] of firm2) / 2
        if any? firms and avg-innovation < mean [innovation-output] of firms [
          die
          let innovative-firms firms with [innovation-output > mean [innovation-output] of firms]
          if any? innovative-firms [
            ask one-of (list firm1 firm2) [
              create-economic-link-with one-of innovative-firms
            ]
          ]
        ]
      ]
    ]

    if count firms > 1 [
      ask firms [
        nw:set-context firms economic-links
        set network-centrality nw:closeness-centrality
      ]
    ]
  ]
end

; =========================
; ENHANCED ECONOMIC MODEL
; =========================
to setup-input-output-matrix
  set num-sectors 15
  set A_matrix matrix:make-constant num-sectors num-sectors 0.1
  let I matrix:make-identity num-sectors
  set I_minus_A_inv matrix:inverse (matrix:minus I A_matrix)
  set demand_vector matrix:make-constant num-sectors 1 100
end

to update-economy-enhanced
  let innovation-multiplier 1 + (total-innovation-output / 10000)
  let dynamic-demand matrix:map [x -> x * innovation-multiplier] demand_vector
  let sector-output matrix:times I_minus_A_inv dynamic-demand

  if any? firms [
    ask firms [
      let sector-output-value matrix:get sector-output sector 0
      set innovation-output innovation-output + (sector-output-value / 100) * production-efficiency
    ]
  ]

  ask patches [
    let local-firms firms-here
    if any? local-firms [
      set economic-activity mean [innovation-output] of local-firms / 100
    ]
  ]
end

; =========================
; ENHANCED VISUALIZATION
; =========================
to update-visualization
  ask households [
    set color scale-color blue cultural-identity 0 (max-cultures - 1)
    set size 0.5 + (income / 100000)
  ]

  if any? firms [
    let max-innov max [innovation-output] of firms
    if max-innov > 0 [
      ask firms [
        set color scale-color red innovation-output 0 max-innov
        set size 1.0 + (r_and_d_budget / 50000)
      ]
    ]
  ]

  ask institutions [
    ifelse policy-focus = "innovation" [ set color blue ] [
      ifelse policy-focus = "diversity" [ set color green ] [ set color yellow ]
    ]
  ]

  ask universities [
    set color scale-color violet knowledge-stock 0 200
  ]

  ask social-links [
    let node1 end1
    let node2 end2
    let cultural-sim 1 - (cultural-distance [cultural-identity] of node1 [cultural-identity] of node2)
    set hidden? cultural-sim < 0.7
  ]

  ask economic-links [
    let firm1 end1
    let firm2 end2
    let interaction-strength ([innovation-output] of firm1 + [innovation-output] of firm2) / 200
    set thickness min (list 1.0 (0.1 + interaction-strength))
  ]
end

; =========================
; ENHANCED METRICS CALCULATION
; =========================
to calculate-enhanced-metrics
  set total-innovation-output (ifelse-value any? firms [ sum [innovation-output] of firms ] [ 0 ])
  set gini-coefficient (ifelse-value any? households [ calculate-gini-coefficient [income] of households ] [ 0 ])
  set segregation-index cultural-segregation-index
  update-diversity-metrics
  set cultural-diversity-index diversity-shannon
  set social-network-clustering network-clustering
  set spatial-autocorrelation spatial-moran-i
  set innovation-concentration-index calculate-innovation-concentration
  set cultural-mixing-index calculate-cultural-mixing
  set knowledge-network-efficiency-score calculate-knowledge-network-efficiency

  ;; New derived metrics
  set share-innovators                share-innovators-of
  set cross-cultural-link-share       cross-cultural-link-share-of
  set mean-path-length-firms          mean-path-length-firms-of
  set degree-centralization-firms     degree-centralization-firms-of
  set gentrification-index            gentrification-index-of
end

to-report cultural-diversity-distinct-count
  report length remove-duplicates [ cultural-identity ] of households
end

to-report cultural-diversity-normalized
  if max-cultures <= 1 [ report 0 ]
  report cultural-diversity-distinct-count / max-cultures
end

to-report cultural-diversity-simpson
  let n count households
  if n = 0 [ report 0 ]
  let groups remove-duplicates [ cultural-identity ] of households
  let sumsq 0
  foreach groups [
    g ->
    let k count households with [ cultural-identity = g ]
    let p k / n
    set sumsq sumsq + (p * p)
  ]
  report (1 - sumsq)
end

to-report shannon-of [attribute-list]
  let n length attribute-list
  if n = 0 [ report 0 ]
  let uniques remove-duplicates attribute-list
  let H 0
  foreach uniques [
    g ->
    let k length filter [ x -> x = g ] attribute-list
    let p k / n
    set H H + (- p * ln p)
  ]
  report H
end

to-report calculate-innovation-concentration
  let total-innov total-innovation-output
  if total-innov = 0 or not any? firms [ report 0 ]
  let sum-sq sum [ (innovation-output / total-innov) ^ 2 ] of firms
  report sum-sq
end

to-report calculate-cultural-mixing
  let total-mixing 0
  let neighborhoods 0
  ask patches [
    let local-households households-here
    if count local-households > 1 [
      let identities [cultural-identity] of local-households
      let shannon shannon-of identities
      set total-mixing total-mixing + shannon
      set neighborhoods neighborhoods + 1
    ]
  ]
  ifelse neighborhoods > 0 [ report total-mixing / neighborhoods ] [ report 0 ]
end

to-report calculate-knowledge-network-efficiency
  nw:set-context firms economic-links
  if count firms < 2 [ report 0 ]
  let path-length nw:mean-path-length
  let clustering social-network-clustering
  if (is-number? path-length) and (is-number? clustering) and (path-length > 0) [
    report clustering / path-length
  ]
  report 0
end

to-report cultural-segregation-index
  let total-seg 0
  let patches-count 0
  ask patches [
    let local-households households in-radius 3
    if count local-households > 1 [
      let cultural-values [cultural-identity] of local-households
      let diversity-score diversity-of cultural-values
      let segregation-score 1 - diversity-score
      set total-seg total-seg + segregation-score
      set patches-count patches-count + 1
    ]
  ]
  ifelse patches-count > 0 [ report total-seg / patches-count ] [ report 0 ]
end

to-report diversity-of [attribute-list]
  let n length attribute-list
  if n = 0 [ report 0 ]
  let uniques remove-duplicates attribute-list
  let counts map [ v -> length filter [ x -> x = v ] attribute-list ] uniques
  let props map [ c -> c / n ] counts
  report 1 - sum (map [ p -> p * p ] props)
end

to-report network-clustering
  nw:set-context firms economic-links
  if not any? firms [ report 0 ]
  report mean [ nw:clustering-coefficient ] of firms
end

to-report spatial-moran-i
  let n count firms
  if n < 2 [ report 0 ]
  let xbar mean [ innovation-output ] of firms
  let denom sum [ (innovation-output - xbar) ^ 2 ] of firms
  if denom = 0 [ report 0 ]
  let num 0
  let S0 0
  ask firms [
    let di (innovation-output - xbar)
    let nbrs other firms in-radius knowledge-spillover-radius
    let k count nbrs
    if k > 0 [
      set num num + sum [ (innovation-output - xbar) * di ] of nbrs
      set S0 S0 + k
    ]
  ]
  if S0 = 0 [ report 0 ]
  report ( (n / S0) * (num / denom) )
end

; =========================
; NEW REPORTERS AND HELPERS
; =========================
to init-firm-innovation-flags
  ;; Reset flags & ensure numeric fields
  ask firms [
    if not is-boolean? innovator?       [ set innovator? false ]
    if not is-boolean? adopted?         [ set adopted? false ]
    if not is-number? innovation-score  [ set innovation-score 0 ]
  ]

  if count firms > 0 [
    ;; Base share modulated by initial cultural diversity:
    ;; More cultures -> fragmented ecosystem -> fewer innovators at start
    let base-share 0.025
    let cultural-modifier max list 0.05 (1 - (initial-cultures / 40))
    let target-share base-share * cultural-modifier

    ;; Minimum number of innovators = 2 to avoid total absence
    let n-innovators max list 2 round (target-share * count firms)

    ;; Threshold for "high potential": uses quantile instead of fixed value
    let high-pot-threshold innovation-potential-quantile 0.75
    let candidates firms with [ innovation-potential >= high-pot-threshold ]

    ;; If few candidates, relax the threshold
    if count candidates < n-innovators [
      let threshold innovation-potential-quantile 0.50
      set candidates firms with [ innovation-potential >= threshold ]
    ]
    if count candidates < n-innovators [
      set candidates firms
    ]

    ask n-of n-innovators candidates [
      set innovator? true
      ;; Innovation-score proportional to potential * absorption capacity (if present)
      let kac ifelse-value (is-number? knowledge-absorption-capacity) [ knowledge-absorption-capacity ] [ 0.5 ]
      set innovation-score (innovation-potential * kac * 100) + random-float 5
    ]
  ]

  ;; (Optional) update an internal metric if used
  ;; update-innovation-metrics
end

to-report share-innovators-of
  if count firms = 0 [ report 0 ]
  report count firms with [ innovator? = true ] / count firms
end

to-report cross-cultural-link-share-of
  let L social-links
  if count L = 0 [ report 0 ]
  let cross count L with [
    [breed] of end1 = households and
    [breed] of end2 = households and
    [cultural-identity] of end1 != [cultural-identity] of end2
  ]
  report cross / count L
end

to-report mean-path-length-firms-of
  if count firms < 2 [ report 0 ]
  nw:set-context firms economic-links
  let mpl nw:mean-path-length
  report ifelse-value is-number? mpl [ mpl ] [ 0 ]
end

to-report degree-centralization-firms-of
  if count firms = 0 [ report 0 ]
  nw:set-context firms economic-links
  let degs [ count link-neighbors ] of firms
  let n length degs
  if n <= 2 [ report 0 ]
  let maxdeg max degs
  let sumdiff sum (map [ d -> maxdeg - d ] degs)
  report safe-div sumdiff ((n - 1) * (n - 2)) 0
end

to-report gentrification-index-of
  let xs []
  let ys []
  ask patches [
    let hh households-here
    if any? hh [
      set xs lput housing-cost xs
      set ys lput mean [ income ] of hh ys
    ]
  ]
  if length xs < 3 [ report 0 ]
  report pearson-r xs ys
end

to-report pearson-r [xs ys]
  let n length xs
  if n != length ys or n = 0 [ report 0 ]
  let mx mean xs
  let my mean ys
  ;; dot product: 2 lists as input to map
  let num sum (map [[x y] -> (x - mx) * (y - my)] xs ys)
  ;; denominator: parentheses around map
  let den (sqrt (sum (map [x -> (x - mx) ^ 2 ] xs))) * (sqrt (sum (map [y -> (y - my) ^ 2 ] ys)))
  report safe-div num den 0
end

; =========================
; DATA EXPORT AND ANALYSIS
; =========================
to export-all-data
  if ticks = 0 [
    setup-export-files
  ]
  ask households [
    append-csv-row "households_data.csv"
      (list ticks who income cultural-identity bonding-capital bridging-capital education-level cultural-tolerance cultural-innovation-tendency)
  ]
  ask firms [
    append-csv-row "firms_data.csv"
      (list ticks who sector innovation-output r_and_d_budget human-capital cultural-diversity network-centrality production-efficiency subsidy-received learning-curve-factor)
  ]
  append-csv-row "summary_metrics.csv"
    (list
      ticks
      total-innovation-output
      gini-coefficient
      segregation-index
      diversity-shannon
      diversity-simpson
      social-network-clustering
      spatial-autocorrelation
      innovation-concentration-index
      cultural-mixing-index
      knowledge-network-efficiency-score
      policy-innovation-effectiveness
      policy-diversity-effectiveness
      policy-equity-effectiveness
      share-innovators
      t50-innovators
      cross-cultural-link-share
      mean-path-length-firms
      degree-centralization-firms
      gentrification-index
    )
  if ticks mod 50 = 0 [
    export-network-data
  ]
end

to setup-export-files
  foreach ["households_data.csv" "firms_data.csv" "summary_metrics.csv" "economic_network.csv"] [
    f -> if file-exists? f [ file-delete f ]
  ]
  append-csv-row "households_data.csv" (list "tick" "id" "income" "cultural_identity" "bonding_capital" "bridging_capital" "education" "tolerance" "innovation_tendency")
  append-csv-row "firms_data.csv" (list "tick" "id" "sector" "innovation" "R&D" "human_capital" "cultural_diversity" "centrality" "efficiency" "subsidies" "learning_curve")
  append-csv-row "summary_metrics.csv" (list
    "tick"
    "total_innovation"
    "gini-coefficient"
    "segregation"
    "diversity_shannon"
    "diversity_simpson"
    "network_clustering"
    "spatial_autocorr"
    "innovation_concentration"
    "cultural_mixing"
    "network_efficiency"
    "policy_innovation_eff"
    "policy_diversity_eff"
    "policy_equity_eff"
    "share_innovators"
    "t50_innovators"
    "cross_cultural_link_share"
    "mean_path_length_firms"
    "degree_centralization_firms"
    "gentrification_index"
  )
  append-csv-row "economic_network.csv" (list "tick" "from" "to" "from_innovation" "to_innovation")
end

to export-network-data
  ask economic-links [
    append-csv-row "economic_network.csv"
      (list ticks [who] of end1 [who] of end2 [innovation-output] of end1 [innovation-output] of end2)
  ]
end

to append-csv-row [path row]
  file-open path
  file-print csv:to-row row
  file-close
end

; =========================
; UTILITY FUNCTIONS
; =========================
to-report mean-innovation
  if count firms = 0 [ report 0 ]
  report mean [innovation-output] of firms
end

to-report std-dev-innovation
  if count firms < 2 [ report 0 ]
  let avg mean [innovation-output] of firms
  let sum-sq sum [ (innovation-output - avg) ^ 2 ] of firms
  report sqrt (sum-sq / (count firms - 1))
end

to-report innovation-inequality
  ;; ROBUST VERSION FOR THESIS
  if not any? firms [ report 0 ]
  let innovations [innovation-output] of firms
  if empty? innovations [ report 0 ]
  if sum innovations = 0 [ report 0 ]
  report calculate-gini-coefficient innovations
end

to-report clip [x lo hi]
  report max list lo min list hi x
end

to-report safe-exp [x]
  report exp (min list 700 x)
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CULTURAL DYNAMICS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to cultural-mutation-step
  let jump-prob 0.2
  ;; If diversity is collapsing, increase probability of global jumps:
  if cultural-diversity-index < 0.3 [ set jump-prob 0.5 ]
  if cultural-diversity-index < 0.15 [ set jump-prob 0.8 ]

  ask households [
    if mutation-prob > 0 and random-float 1 < mutation-prob [
      ifelse random-float 1 < (1 - jump-prob)
      [
        ;; Small local step (+1 or -1)
        let offset one-of [-1 1]
        let new-id cultural-identity + offset
        if new-id >= 0 and new-id < max-cultures [
          set cultural-identity new-id
        ]
      ]
      [
        ;; Global jump (complete change)
        set cultural-identity random max-cultures
      ]
    ]
  ]
end

to cultural-imitation-step
  ask households [
    if (is-number? imitation-prob) and imitation-prob > 0 and random-float 1.0 < imitation-prob [
      let nbrs other households in-radius 3
      if any? nbrs [
        let total sum [bridging-capital] of nbrs
        ;; Weighted choice proportional to bridging-capital; fallback to random if all weights are zero
        let influencer ifelse-value (total <= 0)
          [ one-of nbrs ]
          [ max-one-of nbrs [ random-float (max list 1e-9 bridging-capital) ] ]
        set cultural-identity [cultural-identity] of influencer
      ]
    ]
  ]
end

to update-diversity
  ;; Raw entropy (Shannon) based on current cultural state
  set diversity-shannon cultural-diversity-shannon

  ;; Normalization relative to initial active cultures
  let effective-cultures max list 2 initial-cultures
  let max-div ln effective-cultures

  if max-div > 0 [
    ;; Diffusion factor limited to avoid runaway
    let diffusion-factor min list 1.2 (0.5 + cultural-diffusion-rate)

    ;; Normalized index
    let diversity-normalized diversity-shannon / max-div

    ;; Optional logarithmic damping (enable if saturation is observed)
    ;; set diversity-normalized ln (1 + diversity-normalized)

    set cultural-diversity-index diversity-normalized * diffusion-factor
  ]
end

to-report cultural-diversity-shannon
  if not any? households [ report 0 ]
  let n count households
  let groups remove-duplicates [ cultural-identity ] of households
  let k length groups
  if k <= 1 [ report 0 ]
  let H 0
  foreach groups [
    g ->
    let c count households with [ cultural-identity = g ]
    let p c / n
    if p > 0 [ set H H - (p * ln p) ]
  ]
  report safe-div H (ln k) 0
end

to update-diversity-metrics
  update-diversity
end

; =========================
; ENHANCED UNIVERSITY RESEARCH
; =========================
to conduct-research-enhanced
  ask universities [
    let efficiency-multiplier 1.0
    if research-focus = "applied" [ set efficiency-multiplier 1.2 ]
    if research-focus = "interdisciplinary" [ set efficiency-multiplier 1.1 ]

    let research-output research-budget * 0.01 * random-float 1.0 * efficiency-multiplier
    set knowledge-stock knowledge-stock + research-output

    let nearby-firms firms in-radius knowledge-spillover-radius
    let spillover-multiplier 0.5 * collaboration-intensity
    ask nearby-firms [
      set innovation-output innovation-output + (research-output * spillover-multiplier)
    ]

    if random-float 1 < 0.05 [
      let successful-firms count firms with [innovation-output > 100]
      if successful-firms > count firms / 3 [
        set research-focus "applied"
      ]
    ]
  ]
end

to-report current-share-innovators
  if count firms = 0 [ report 0 ]
  report (count firms with [ innovator? ]) / count firms
end

to-report network-degree-score
  if count firms = 0 [ report 0 ]
  report mean [ count my-economic-links ] of firms
end

to-report network-density-score
  let n count firms
  if n <= 1 [ report 0 ]
  report (count economic-links) / ((n * (n - 1)) / 2)
end

to-report adoption-speed-metric
  ;; Returns the tick when the 25% threshold is exceeded
  report adoption-speed-t25
end

to-report adoption-speed-avg
  ;; Average adoption speed (share/ticks)
  if ticks = 0 [ report 0 ]
  report current-share-innovators / ticks
end

to update-adoption-metrics
  ;; Historical maximum
  if current-share-innovators > max-share-innovators [
    set max-share-innovators current-share-innovators
  ]

  ;; T10
  if t10-innovators = -1 and current-share-innovators >= 0.10 [
    set t10-innovators ticks
  ]

  ;; T25 (adoption-threshold)
  if adoption-speed-t25 = -1 and current-share-innovators >= adoption-threshold [
    set adoption-speed-t25 ticks
  ]

  ;; T50
  if t50-innovators = -1 and current-share-innovators >= 0.50 [
    set t50-innovators ticks
  ]

  ;; Early slope (first 5 ticks)
  if ticks < 6 [
    set early-adoption-cumulative early-adoption-cumulative + current-share-innovators
    if ticks = 5 [
      set early-adoption-slope early-adoption-cumulative / 5
    ]
  ]

  ;; Saturation
  if current-share-innovators >= 0.90 [
    set adoption-saturated? true
  ]
end

to-report total-rd-cost
  if not any? firms [ report 0 ]
  report sum [ r_and_d_budget ] of firms
end

to reset-adoption-metrics
  set max-share-innovators 0
  set adoption-speed-t25 -1
  set t10-innovators -1
  set t50-innovators -1
  set early-adoption-cumulative 0
  set early-adoption-slope 0
  set adoption-saturated? false
  if not is-number? adoption-threshold [ set adoption-threshold 0.25 ]
end

to maybe-create-bridging-link
  ;; Creates culturally bridging links with probability scaled by bridging-capital-weight.
  if count households < 2 [ stop ]
  let p min list 0.05 (0.005 + bridging-capital-weight * 0.01)
  if random-float 1 >= p [ stop ]

  let src one-of households
  if src = nobody [ stop ]
  let candidates households with [
    self != src and
    not link-neighbor? src and
    abs (cultural-identity - [cultural-identity] of src) > 2
  ]
  if not any? candidates [ stop ]
  let tgt one-of candidates

  ask src [
    ;; Use create-social-link-with if you defined social-links; otherwise create-link-with
    create-link-with tgt [
      set color blue - 2
      set thickness 0.2
    ]
  ]
end

to-report list-quantile [vals q]
  if empty? vals [ report 0 ]
  let sorted sort vals
  let n length sorted
  let pos q * (n - 1)
  let lower floor pos
  let upper ceiling pos
  if lower = upper [
    report item lower sorted
  ]
  let w pos - lower
  report ((1 - w) * item lower sorted) + (w * item upper sorted)
end

to-report innovation-potential-quantile [q]
  ;; q must be in [0,1]
  if count firms = 0 [ report 0 ]
  let vals sort [innovation-potential] of firms
  let n length vals
  let pos q * (n - 1)
  let lower floor pos
  let upper ceiling pos
  if lower = upper [
    report item lower vals
  ]
  let w pos - lower
  report ((1 - w) * item lower vals) + (w * item upper vals)
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
19
31
191
64
num-households
num-households
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
12
86
184
119
num-firms
num-firms
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
30
146
202
179
num-institutions
num-institutions
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
23
218
195
251
num-universities
num-universities
0
100
50.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
