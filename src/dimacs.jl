include("my_types.jl")

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


if abspath(PROGRAM_FILE) == @__FILE__
    clauses, (num_vars, num_clauses) = read_dimacs("inputs/toy_simple.cnf")
    println("Number of variables: ", num_vars)
    println("Number of clauses: ", num_clauses)
    println("Clauses: ", clauses)
end