include("my_types.jl")

"""
Read the DIMACS file and return the clauses and the number of variables and clauses
"""
function read_dimacs(filename::String)::Tuple{Formula, Tuple{Int, Int}}
    lines = readlines(filename)

    clauses = Formula()
    for line in lines
        # skip comments and problem line
        if startswith(line, "c") || startswith(line, "p")
            continue
        end

        # skip if line is empty
        if isempty(strip(line))
            continue
        end

        # weird stuff
        if strip(line) == "%" || strip(line) == "0"
            continue
        end
        

        # parse clause
        clause = [parse(Int, x) for x in split(strip(line)) if x != "0"]
        push!(clauses, clause)
    end

    # calculate the number of clauses
    num_clauses = length(clauses)

    # calculate the number of variables
    flat = collect(Iterators.flatten(clauses))
    num_vars = maximum(abs.(flat))

    return clauses, (num_vars, num_clauses)
end

function initialize_watched_literals(clauses::Formula)::WatchedLiterals
    watched_literals = WatchedLiterals(Dict(), zeros(Literal, length(clauses), 2))

    for (i, clause) in enumerate(clauses)
        # choose the first two literals to watch
        l1, l2 = clause[1], clause[2]

        # add the literals to the watchlists
        push!(get!(watched_literals.watchlists, l1, Int[]), i)
        push!(get!(watched_literals.watchlists, l2, Int[]), i)

        # add the literals to the warrays
        watched_literals.warray[i, :] = [l1, l2]
    end

    # make sure we don't have any 0s remaining in the warray
    @assert all(x -> x != 0, watched_literals.warray)

    return watched_literals
end


if abspath(PROGRAM_FILE) == @__FILE__
    clauses, (num_vars, num_clauses) = read_dimacs("inputs/toy_simple.cnf")
    println("Number of variables: ", num_vars)
    println("Number of clauses: ", num_clauses)
    println("Clauses: ", clauses)
end