# QAP-Metaheuristics
Metaheuristics for solving the Quadratic Assignment Problem (QAP), as part of the course INF2980 (Metaheuristics) in PUC-Rio.

### Dependencies
This project was developed using Julia 1.1.0

### Instructions
To run a single experiment (on a single instance), you may run program/Main.jl, for example as:

```
julia program/Main.jl <instance_path> --cpu_time 200 --seed 0
```

To run multiple experiments (grid search over parameters), you may run program/MultipleExperimentsGA.jl
