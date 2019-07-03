# QAP-Metaheuristics
Metaheuristics for solving the Quadratic Assignment Problem (QAP), as part of the course INF2980 (Metaheuristics) in PUC-Rio.

Problem instances were obtained from QAPLIB: http://anjos.mgi.polymtl.ca/qaplib/

### Dependencies
This project was developed using Julia 1.1.0

### Instructions
To run a single experiment (on a single instance), you may run program/Main.jl, for example as:

```
julia program/Main.jl <instance_path> --cpu_time 200 --seed 0
```

To run multiple experiments (grid search over parameters), you may run program/MultipleExperimentsGA.jl

### References
- Zvi Drezner, 2008 – Extensive experiments with hybrid genetic algorithms for the solution of the quadratic assignment problem
- Zvi Drezner, 2003 – A New Genetic Algorithm for the Quadratic Assignment Problem
- Burkard et al., 1984 – The Quadratic Assignment Problems
- Vidal, T. et al., 2012 - A hybrid genetic algorithm for multidepot and periodic vehicle routing problems
