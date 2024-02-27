
include("my_types.jl")
include("utils.jl")
using DataStructures
using PrettyPrint

"""
Solve the given formula using the DPLL algorithm.
"""
function solve!(num_vars::Int, clauses::Formula, watched_literals::WatchedLiterals, decision_stack::DecisionStack)::SatResult
    # initialize the assignments
    new_assignments = Assignments()

    while true
        # decide the next variable to assign, add it to the decision stack
        decision = decide!(num_vars, new_assignments)

        # if there are no more variables to assign, we are done
        if decision == false
            return SAT
        end

        println("")
        println("Decision: ", decision)

        # otherwise, push the new assignments to the decision stack
        push!(decision_stack, (decision, new_assignments))

        println("Decision stack: ", decision_stack)

        # we need to do BCP on the decision
        while !bcp!(decision, clauses, watched_literals, last(decision_stack)[2])
            # if BCP results in a conflict, we need to resolve it
            resolution = resolve_conflict!(decision_stack)

            # if resolution is not possible, return UNSAT
            if resolution == false
                return UNSAT
            end

            # resolve_conflict! will have updated the decision stack with the new decision
            decision = last(decision_stack)[1]
            println("")
            println("New decision: ", decision)
        end

        # bcp_out = bcp!(decision, clauses, watched_literals, last(decision_stack)[2])
        # if bcp_out == false
        #     # if BCP results in a conflict, we need to resolve it
        #     resolution = resolve_conflict!(decision_stack)

        #     # if resolution is not possible, return UNSAT
        #     if resolution == false
        #         return UNSAT
        #     end
        # end

        # copy the last assignments and make them the new ones
        _, new_assignments = deepcopy(last(decision_stack))
    end
end


"""
Remove off the decision stack until the conflict is resolved
"""
function resolve_conflict!(decision_stack::Vector{Tuple{Literal, Assignments}})
    println("Conflict found! Resolving...")

    # pop until we have an empty decision stack
    while length(decision_stack) > 0
        # peek at the last decision
        decision, _ = last(decision_stack)

        @assert decision != 0 

        # since we only decide on true, if we find the decision is a true literal
        # then we know it hasn't been tried both ways. we can flip the decision then
        if decision < 0
            pop!(decision_stack)
        else
            # flip the decision to false
            new_decision = -decision
            @assert new_decision < 0

            # remove the last decision with its assignments
            pop!(decision_stack)

            # copy the parent's assignments if possible (not root)
            if length(decision_stack) > 0
                _, new_assignments = deepcopy(last(decision_stack))
            else
                new_assignments = Assignments()
            end

            # set the new decision to false
            new_assignments[abs(new_decision)] = false

            # push the new decision and assignments to the stack
            # we have resolved the conflict and return true
            push!(decision_stack, (new_decision, new_assignments))
            return true
        end
    end

    # if we didn't find a decision to flip, then we know we have tried all
    # possible assignments and the formula is unsatisfiable
    return false
end

"""
Decide the next variable to assign
"""
function decide!(num_vars::Int, assignments::Assignments)::Union{Literal, Bool}
    # choose first unassigned variable TODO: better heuristics
    variable = nothing
    for i in 1:num_vars
        if i ∉ keys(assignments)
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

    return variable
end


"""
Do Boolean Constraint Propagation (BCP) on the given formula
"""
function bcp!(literal::Int, clauses::Formula, watched_literals::WatchedLiterals, assignments::Assignments)::Bool
    # initialize a queue to propagate
    propagation_stack::Vector{Int} = [literal]

    while length(propagation_stack) > 0
        # pop the next literal to propagate
        current_literal = pop!(propagation_stack)

        # assign the literal
        assign_true!(current_literal, assignments)

        # maintain the invariant for the literal
        output = two_watch_invariant!(current_literal, clauses, watched_literals, assignments)

        # if the clause is unsatisfied, return false
        if output == false
            return false
        end

        @assert typeof(output) == Vector{Literal}
        println("Units found: ", output)

        # otherwise we have a bunch of units we add to the queue
        append!(propagation_stack, output)
    end

    # if we are done, return true (no conflict)
    return true
end

"""
Maintain the two-watched literals invariant for the given literal
"""
function two_watch_invariant!(literal::Int, clauses::Formula, watched_literals::WatchedLiterals, assignments::Dict{Int, Bool})::Union{Bool, Vector{Literal}}
    # get the watchlist for the opposite literal
    watchlist = get(watched_literals.watchlists, -literal, Int[])

    # queue for found unit clauses
    unit_queue = Vector{Literal}()

    # for each clause in the watchlist of that opposite literal
    for clause_index in watchlist
        # we have two watched literals l1 and l2
        # l2 is our -literal, which has just been assigned to false
        currently_watched = watched_literals.warray[clause_index, :]
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

            # make sure the potential literal is not falsified
            if is_literal_true(potential_literal, assignments) == false
                continue
            end

            # we found a new literal to watch!
            new_literal = potential_literal

            # update the watchlist and warray
            push!(get!(watched_literals.watchlists, new_literal, Int[]), clause_index)
            watched_literals.warray[clause_index, :] = [l1, new_literal]
            
            # exit the loop for this clause once we find a new literal to watch
            break
        end

        # TODO: debugging only, remove later
        # if isnothing(new_literal)
        #     println("did not find new literal to watch")
        # end

        # if we didn't find a new literal to watch, and l1 is false
        # then the clause is unsatisfied (all literals are false)
        if isnothing(new_literal) && l1_status == FALSE
            println("all false, clause is unsatisfied")
            return false
        end

        # if we didn't find a new literal to watch, and l1 is unassigned
        # then the clause is unit clause and l1 is the unit that must be true
        if isnothing(new_literal) && l1_status == UNASSIGNED
            push!(unit_queue, l1)
        end
    end


    # after we look at all clauses, we are done, return units
    return unit_queue
end