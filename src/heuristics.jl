include("my_types.jl")


function conflict_increase!(conflicts::Vector{Float32}, clause::Vector{Int16})
    for literal in clause
        conflicts[abs(literal)] += 1
    end
end


function conflict_halve!(conflicts::Vector{Float32})
    for i in 1:length(conflicts)
        conflicts[i] /=  2
    end
end

function conflict_compute!(conflicts::Vector{Float32})::Vector{Int16}
    return sortperm(conflicts, rev=true)
end


function pick_variable_conflicts!(conflicts_idx, assignments::Assignments)::Union{Int16, Bool}
    variable = nothing
    for i in conflicts
        if i ∉ keys(assignments)
            variable = i
            break
        end
    end

    if isnothing(variable)
        return false
    end

    assignments[variable] = true

    return variable
end

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