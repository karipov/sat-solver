include("my_types.jl")

"""
Read the DIMACS file and return the clauses and the number of variables and clauses
"""
function read_dimacs(filename::String)::Tuple{Formula, Tuple{Int16, Int16}}
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
        clause = [parse(Int16, x) for x in split(strip(line)) if x != "0"]
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
        for literal in clause
            push!(get!(watched_literals.watchlists, literal, Int16[]), i)
        end

    end

    return watched_literals
end


function output_as_json(filename::String, decision_stack::DecisionStack, status::SatResult, time::Float64)
    json = Vector()

    push!(json, ("Instance", split(filename, "/")[end]))
    push!(json, ("Time", time))

    if status == SAT
        push!(json, ("Status", "SAT"))
        solution = last(decision_stack)[2]
        solution_list = [(k, v) for (k, v) in solution]
        sort!(solution_list)
        push!(json, ("Solution", join([string(k, " ", v) for (k, v) in solution_list], " ")))
    else
        push!(json, ("Status", "UNSAT"))
    end

    return jsonify(json)
end


function jsonify(dict::Vector)::String
    output_str = "{"

    for (key, value) in dict
        if typeof(value) == String
            output_str *= "\"$key\": \"$value\""
        elseif typeof(value) == Float64
            output_str *= "\"$key\": $(round(value, digits=2))"
        else
            output_str *= "\"$key\": $value"
        end

        output_str *= ", "
    end

    output_str = replace(output_str, r", $"=>"")
    output_str *= "}"

    return output_str
end


if abspath(PROGRAM_FILE) == @__FILE__
    clauses, (num_vars, num_clauses) = read_dimacs("inputs/toy_simple.cnf")
    println("Number of variables: ", num_vars)
    println("Number of clauses: ", num_clauses)
    println("Clauses: ", clauses)
end