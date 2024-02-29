Formula = Vector{Vector{Int16}}
Assignments = Dict{Int16, Bool}
Literal = Int16
DecisionStack = Vector{Tuple{Literal, Assignments}}

struct WatchedLiterals
    # watchlists[literal] = [clause_index1, clause_index2, ...]
    watchlists::Dict{Literal, Vector{Int16}}

    # warray[clause_index] = (watched_literal1, watched_literal2)
    warray::Array{Literal, 2}
end

@enum SatResult UNSAT=0 SAT=1

@enum AssignResult UNASSIGNED=0 TRUE=1 FALSE=2

@enum BranchResult UNIT=0 SATISFIED=1 UNSATISFIED=2