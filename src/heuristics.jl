include("my_types.jl")

"""
Calculate two-sided Jeroslow-Wang heuristic
"""
function jeroslow_wang(num_vars::Int16, clauses::Formula)::Vector{Int16}
    jw = zeros(Float32, num_vars)

    for clause in clauses
        for literal in clause
            jw[abs(literal)] += 2.0^-length(clause)
        end
    end

    indices = sortperm(jw, rev=true)
    return map(Int16, indices)
end

"""
Pick the variable with the highest Jeroslow-Wang score
"""
function pick_variable_jw!(jw_indices::Vector{Int16}, assignments::Assignments)::Union{Int16, Bool}

    variable = nothing
    for i in jw_indices
        if i ∉ keys(assignments)
            variable = i
            break
        end
    end

    if isnothing(variable)
        return false
    end

    # assign the variable to true TODO: default is true?
    assignments[variable] = true

    return variable
end

"""
Decide randomly the next variable to assign
"""
function random_decide!(num_vars::Int16, assignments::Assignments)::Union{Literal, Bool}
    # choose first unassigned variable TODO: better heuristics
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