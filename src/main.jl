include("dimacs.jl")
include("dpll.jl")
include("verification.jl")

using PrettyPrint


function main()
    clauses, (num_vars, num_clauses) = read_dimacs("inputs/upenn.cnf")
    println("Number of variables: ", num_vars)
    println("Number of clauses: ", num_clauses)
    println("Clauses: ", clauses)
    println("")

    # initialize some things
    watched_literals = initialize_watched_literals(clauses)
    decision_stack = Vector{Tuple{Literal, Assignments}}()

    println("Watched Literals: ", watched_literals)

    # run the DPLL algorithm
    sat_result = solve!(num_vars, clauses, watched_literals, decision_stack)

    println("")    
    # output the solution
    if sat_result == UNSAT
        println("UNSAT")
    else
        println("SAT")
        println("Solution: ")
        pprint(last(decision_stack)[2])
        println("\nVerified?: ", verify(clauses, last(decision_stack)[2]))
    end
    
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end