include("my_types.jl")

"""
Calculate two-sided Jeroslow-Wang heuristic
"""
function jeroslow_wang!(assignments::Assignments, clauses::Formula, jw_weights::Vector{Float32}, jw_indices::Vector{Int16})::Bool
    # reset the weights
    fill!(jw_weights, zero(Float32))

    sat_clause_counter = Int16(0)
    # calculate the weights
    for clause in clauses
        # don't consider the clause if it's already satisfied
        if is_clause_satisfied(clause, assignments)
            sat_clause_counter += 1
            continue
        end

        # proportion of clause length
        for literal in clause
            jw_weights[abs(literal)] += 2.0^-length(clause)
        end
    end

    sortperm!(jw_indices, jw_weights, rev=true, alg=QuickSort)

    return (sat_clause_counter == length(clauses))
end

"""
Pick the variable with the highest Jeroslow-Wang score
Randomize slightly
"""
function pick_variable_jw!(jw_indices::Vector{Int16}, assignments::Assignments)::Union{Int16, Bool}
    # choose randomly from the top 3 unassigned variables
    top_k_variables = Int16[]

    variable = nothing
    for i in jw_indices
        if i ∉ keys(assignments)
            push!(top_k_variables, i)

            if length(top_k_variables) >= 3
                break
            end
        end
    end

    if isempty(top_k_variables)
        return false
    end

    # Randomly pick one of the up to 3 unassigned variables
    variable = rand(top_k_variables)

    # assign the variable to true
    assignments[variable] = true

    return variable
end

"""
Decide randomly the next variable to assign
"""
function random_decide!(num_vars::Int16, assignments::Assignments)::Union{Literal, Bool}
    # choose first unassigned variable
    variable = nothing
    for i in Int16(1):num_vars
        if i ∉ keys(assignments)
            variable = i
            break
        end
    end

    # no more variables to assign, we are done
    if isnothing(variable)
        return false
    end

    assignments[variable] = true

    return variable
end

# function conflict_increase!(clause::Vector{Int16})
#     global CONFLICTS

#     for literal in clause
#         CONFLICTS[abs(literal)] += 1
#     end
# end

# function conflict_halve!()
#     global CONFLICTS

#     CONFLICTS /= 2
# end

# function conflict_compute!()
#     global CONFLICTS, CONFLICTS_IDX

#     indices = sortperm(CONFLICTS, rev=true)
#     CONFLICTS_IDX = map(Int16, indices)
# end

# function pick_variable_conflicts!(assignments::Assignments)::Union{Int16, Bool}
#     global CONFLICTS_IDX

#     variable = nothing
#     for i in CONFLICTS_IDX
#         if i ∉ keys(assignments)
#             variable = i
#             break
#         end
#     end

#     if isnothing(variable)
#         return false
#     end

#     assignments[variable] = true

#     return variable
# end