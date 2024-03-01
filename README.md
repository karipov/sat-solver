# DPLL SAT Solver

### File directory overview

- `src/dpll.jl`: main DPLL algorithm including BCP and conflict resolution
- `src/heuristics.jl`: contains heuristics for jeroslaw-wang, random, and unit-preference
- `src/processors.jl`: reads in DIMACS, outputs JSON
- `src/utils.jl`: variable assignment, truth checking and other utilities
- `src/verification.jl`: checks if a solution is valid
- `src/main.jl`: main entry point for running the solver
