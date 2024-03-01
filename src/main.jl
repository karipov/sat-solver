include("processors.jl")
include("dpll.jl")
include("verification.jl")
include("heuristics.jl")

# # global conflicts counter
# CONFLICTS = nothing
# CONFLICTS_IDX = nothing

function main()
    clauses, (num_vars, num_clauses) = read_dimacs(ARGS[1])
    println("Number of variables: ", num_vars)
    println("Number of clauses: ", num_clauses)
    println("")

    # initialize some things
    watched_literals = initialize_watched_literals(clauses)
    decision_stack = Vector{Tuple{Literal, Assignments}}()

    # global CONFLICTS, CONFLICTS_IDX
    # CONFLICTS = zeros(Float32, num_vars)
    # CONFLICTS_IDX = Vector{Int16}()

    start_time = time()

    # calcualte jw once (static)
    jw_indices = jeroslow_wang(num_vars, clauses)
    # run the DPLL algorithm
    sat_result = solve!(num_vars, clauses, watched_literals, decision_stack, jw_indices)

    end_time = time()

    if length(decision_stack) > 0
        println("Verified? ", verify(clauses, decision_stack[end][2]))
    end

    println()
    println(output_as_json(ARGS[1], decision_stack, sat_result, end_time - start_time))
end


if abspath(PROGRAM_FILE) == @__FILE__
    main()
end