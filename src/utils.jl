include("my_types.jl")

function is_literal_true(literal::Int, assignments::Assignments)::AssignResult
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

function assign_true!(literal::Int, assignments::Assignments)
    variable = abs(literal)
    assignments[variable] = (literal > 0)
end