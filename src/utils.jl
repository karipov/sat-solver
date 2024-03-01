include("my_types.jl")


"""
Checks if the assignments satisfy the given literal
"""
function is_literal_true(literal::Literal, assignments::Assignments)::AssignResult
    variable = abs(literal)
    if haskey(assignments, variable)
        if (literal > 0) == assignments[variable]
            return TRUE
        else
            return FALSE
        end
    else
        return UNASSIGNED # unassigned case
    end
end

"""
Assign a literal such that it's true
"""
function assign_true!(literal::Literal, assignments::Assignments)
    variable = abs(literal)
    assignments[variable] = (literal > 0)
end

function is_clause_satisfied(clause::Vector{Literal}, assignments::Assignments)::Bool
    for literal in clause
        if is_literal_true(literal, assignments) == TRUE
            return true
        end
    end
    return false
end