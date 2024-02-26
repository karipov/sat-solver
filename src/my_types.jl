Formula = Vector{Vector{Int}}
Assignments = Dict{Int, Bool}
Literal = Int

mutable struct WatchedLiterals
    # watchlists[literal] = [clause_index1, clause_index2, ...]
    watchlists::Dict{Literal, Vector{Int}}

    # warray[clause_index] = (watched_literal1, watched_literal2)
    warray::Vector{Vector{Int}} 
end

@enum SatResult UNSAT=0 SAT=1

@enum AssignResult UNASSIGNED=0 TRUE=1 FALSE=2

@enum BranchResult UNIT=0 SATISFIED=1 UNSATISFIED=2