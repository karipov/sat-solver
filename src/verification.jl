include("my_types.jl")
include("utils.jl")

function verify(clauses::Formula, assignments::Assignments)
    for clause in clauses
        clause_satisfied = false
        for literal in clause
            if is_literal_true(literal, assignments) == TRUE
                clause_satisfied = true
                break
            end
        end
        if !clause_satisfied
            println("\nthe clause ", clause, " is not satisfied")
            return false
        end
    end
    return true
end