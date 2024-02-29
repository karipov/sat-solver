
include("my_types.jl")
include("utils.jl")

"""
Solve the given formula using the DPLL algorithm.
"""
function solve!(num_vars::Int16, clauses::Formula, watched_literals::WatchedLiterals, decision_stack::DecisionStack)::SatResult
    # initialize the assignments
    new_assignments = Assignments()

    while true
        # decide the next variable to assign, add it to the decision stack
        decision = decide!(num_vars, new_assignments)

        # if there are no more variables to assign, we are done
        if decision == false
            return SAT
        end

        # otherwise, push the new assignments to the decision stack
        push!(decision_stack, (decision, new_assignments))

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
        end

        # copy the last assignments and make them the new ones
        _, new_assignments = deepcopy(last(decision_stack))
    end
end


"""
Remove off the decision stack until the conflict is resolved
"""
function resolve_conflict!(decision_stack::Vector{Tuple{Literal, Assignments}})::Bool

    # pop until we have an empty decision stack
    while length(decision_stack) > 0
        # peek at the last decision
        decision, _ = last(decision_stack)

        # @assert decision != 0 

        # since we only decide on true, if we find the decision is a true literal
        # then we know it hasn't been tried both ways. we can flip the decision then
        if decision < 0
            pop!(decision_stack)
        else
            # flip the decision to false
            new_decision = -decision
            # @assert new_decision < 0

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
function decide!(num_vars::Int16, assignments::Assignments)::Union{Literal, Bool}
    # choose first unassigned variable TODO: better heuristics
    variable = nothing
    for i in Int16(1):num_vars
        if i ∉ keys(assignments)
            variable = i
            break
        end
    end

    # no more variables to assign
    if isnothing(variable)
        # @assert length(keys(assignments)) == num_vars
        return false
    end

    # assign the variable to true TODO: default is true?
    assignments[variable] = true

    return variable
end


"""
Do Boolean Constraint Propagation (BCP) on the given formula
"""
function bcp!(literal::Int16, clauses::Formula, watched_literals::WatchedLiterals, assignments::Assignments)::Bool
    # initialize a queue to propagate
    propagation_stack::Vector{Int16} = [literal]

    while length(propagation_stack) > 0

        # pop the next literal to propagate
        current_literal = pop!(propagation_stack)

        # assign the literal
        assign_true!(current_literal, assignments)

        # maintain the invariant for the literal
        # TODO: using occurence lists now
        # output = two_watch_invariant!(current_literal, clauses, watched_literals, assignments)
        output = occurence_list!(current_literal, clauses, watched_literals, assignments)


        # if the clause is unsatisfied, return false
        if output == false
            return false
        end

        # otherwise we have a bunch of units we add to the queue
        # @assert typeof(output) == Vector{Literal}
        append!(propagation_stack, output)
    end

    # if we are done, return true (no conflict)
    return true
end


"""
Use watchlist as occurence list
"""
function occurence_list!(literal::Literal, clauses::Formula, watchlist::WatchedLiterals, assignments::Assignments)::Union{Bool, Vector{Literal}}
    watchlist = get!(watchlist.watchlists, -literal, Int16[])

    # queue for found unit clauses
    unit_queue = Vector{Literal}()

    for clause_index in watchlist
        clause = clauses[clause_index]

        # get some clause statistics
        false_counter = 0
        found_true = false
        latest_unassigned = nothing
        for i_literal in clause
            output = is_literal_true(i_literal, assignments)

            if output == TRUE
                found_true = true
                break
            end

            if output == FALSE
                false_counter += 1
            end

            if output == UNASSIGNED
                latest_unassigned = i_literal
            end
        end

        # if the clause is already satisfied, we do nothing
        if found_true
            continue
        end

        # if all literals are false, the clause is unsatisfied
        if false_counter == length(clause)
            return false
        end

        if false_counter == length(clause) - 1
            # find the unassigned literal
            push!(unit_queue, latest_unassigned)
        end

        # -----------------------------------------

        # # if the clause is already satisfied, we do nothing
        # if any(literal -> is_literal_true(literal, assignments) == TRUE, clause)
        #     continue
        # end

        # false_count = count(literal -> is_literal_true(literal, assignments) == FALSE, clause)
        # # if all literals are false, the clause is unsatisfied
        # if false_count == length(clause)
        #     return false
        # end

        # # find the unit literal otherwise
        # unassigned_count = count(literal -> is_literal_true(literal, assignments) == UNASSIGNED, clause)
        # if (length(clause) - 1) == false_count
        #     # find the unassigned literal
        #     unassigned_literal = filter(literal -> is_literal_true(literal, assignments) == UNASSIGNED, clause)[1]
        #     push!(unit_queue, unassigned_literal)
        # end
        
    end

    return unit_queue
end


"""
Maintain the two-watched literals invariant for the given literal
"""
function two_watch_invariant!(literal::Int16, clauses::Formula, watched_literals::WatchedLiterals, assignments::Dict{Int16, Bool})::Union{Bool, Vector{Literal}}
    # get the watchlist for the opposite literal
    watchlist = get!(watched_literals.watchlists, -literal, Int16[])

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

        @assert -literal in currently_watched
        @assert is_literal_true(l2, assignments) == FALSE

        l1_status = is_literal_true(l1, assignments)

        # if l1 is true, we do nothing, the clause is satisfied
        if l1_status == TRUE
            # check if any one of the literals is true under current assignments
            @assert any(literal -> is_literal_true(literal, assignments) == TRUE, clauses[clause_index])            
            continue
        end

        # we need to find a new literal to watch
        new_literal = nothing

        for potential_literal in clauses[clause_index]

            # println("potential literal: $potential_literal")
            # println("potential literal status: ", is_literal_true(potential_literal, assignments))

            # make sure the potential literal is not already watched
            if potential_literal in currently_watched
                # println("potential literal $potential_literal is already watched")
                continue
            end

            # make sure the potential literal is not falsified
            if is_literal_true(potential_literal, assignments) == FALSE
                # println("potential literal $potential_literal is false")
                continue
            end

            # we found a new literal to watch!
            new_literal = potential_literal

            # add the clause to the watchlist of the new literal
            push!(get!(watched_literals.watchlists, new_literal, Int16[]), clause_index)

            # remove the clause from the watchlist of the old literal
            filter!(v -> v != clause_index, watched_literals.watchlists[l2])

            # this clause has a new watcher
            watched_literals.warray[clause_index, :] = [l1, new_literal]
            
            @assert is_literal_true(l2, assignments) == FALSE
            @assert is_literal_true(new_literal, assignments) != FALSE
            
            # exit the loop for this clause once we find a new literal to watch
            break
        end

        # if we didn't find a new literal to watch, and l1 is false
        # then the clause is unsatisfied (all literals are false)
        if isnothing(new_literal) && l1_status == FALSE
            # want to make sure everything is false!
            @assert all(l -> is_literal_true(l, assignments) == FALSE, clauses[clause_index])

            return false
        end

        # if we didn't find a new literal to watch, and l1 is unassigned
        # then the clause is unit clause and l1 is the unit that must be true
        if isnothing(new_literal) && l1_status == UNASSIGNED
            push!(unit_queue, l1)
        end
    end

    # check that all the found units are unassigned
    @assert all(literal -> is_literal_true(literal, assignments) == UNASSIGNED, unit_queue)


    # after we look at all clauses, we are done, return units
    return unit_queue
end