
include("my_types.jl")
include("utils.jl")
using DataStructures

"""
Solve the given formula using the DPLL algorithm.
"""
function solve(clauses::Formula)::Bool
    while true
        if !decide()
            return true
        end

        while !bcp()
            if !resolveConflict()
                return false
            end
        end
    end
end

function decide!(num_vars::Int, decision_stack::Deque{Dict{Int, Bool}})::Bool
    # copy the last assignments from the decision stack
    assignments::Dict{Bool} = last(decision_stack)

    # choose first available variable TODO: better heuristics
    variable = nothing
    for i in 1:num_vars
        if i ∉ assignments
            variable = i
            break
        end
    end

    # no more variables to assign
    if isnothing(variable)
        return false
    end

    # assign the variable to true TODO: default is true?
    assignments[variable] = true

    # push the new assignments to the decision stack
    pushfirst!(decision_stack, assignments)

    return true
end


function bcp()::Bool
    # code
end

function two_watch_invariant!(literal::Int, watched_literals::WatchedLiterals, assignments::Dict{Int, Bool})
    # get the watchlist for the opposite literal
    watchlist = watched_literals.watchlists[-literal]

    # for each clause in the watchlist of that opposite literal
    for clause_index in watchlist
        # we have two watched literals l1 and l2
        # l2 is our -literal, which has just been assigned to false
        currently_watched = watched_literals.warray[clause_index]
        l1, l2 = currently_watched
        if l1 == -literal
            l1, l2 = l2, l1
        end

        l1_status = is_literal_true(l1, assignments)

        # if l1 is true, we do nothing, the clause is satisfied
        if l1_status == TRUE
            continue
        end

        # we need to find a new literal to watch
        new_literal = nothing

        for potential_literal in clauses[clause_index]
            # make sure the potential literal is not already watched
            if potential_literal in currently_watched
                continue
            end

            # make sure the potential literal is not false
            if is_literal_true(potential_literal, assignments) == false
                continue
            end

            # we found a new literal to watch!
            new_literal = potential_literal

            # update the watchlist and warray
            watched_literals.watchlists[new_literal].push!(clause_index)
            watched_literals.warray[clause_index] = [l1, new_literal]
            
            # exit the function
            return true
        end

        # if we didn't find a new literal to watch, and l1 is false
        # then the clause is unsatisfied
        if isnothing(new_literal) && l1_status == FALSE
            return false
        end

        # if we didn't find a new literal to watch, and l1 is unassigned
        # then the clause is unit
        if isnothing(new_literal) && l1_status == UNASSIGNED
            return l1
        end
    end
end