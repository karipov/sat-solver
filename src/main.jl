include("dimacs.jl")
include("dpll.jl")


function main()
    clauses, (num_vars, num_clauses) = read_dimacs("inputs/toy_simple.cnf")
    println("Number of variables: ", num_vars)
    println("Number of clauses: ", num_clauses)
    println("Clauses: ", clauses)

    # solution
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end