import copy

def unit_propagation(sat_instance):
    """
    Perform unit propagation on the given SAT instance.
    """
    print("[UNIT-PROP] starting unit prop")
    unit = None

    # find one unit clause
    for clause in sat_instance.clauses:
        if len(clause) == 1:
            elt = clause.pop()
            clause.add(elt)
            unit = elt
            break
    
    # if we don't find any units, then do nothing
    if not unit:
        print("[UNIT-PROP] did not find any units")
        return

    print("[UNIT-PROP] found unit:", unit)
    # remove all clauses containing the unit
    sat_instance.clauses = [clause for clause in sat_instance.clauses if not unit in clause]
    
    # remove all instances of the negation of the unit from all clauses
    for i in range(len(sat_instance.clauses)):
        sat_instance.clauses[i] = {literal for literal in sat_instance.clauses[i] if not (-literal == unit)}
    
    # assign the unit
    sat_instance.assignments[abs(unit)] = unit > 0
    
    print("[UNIT-PROP] clauses after unit prop:", sat_instance.clauses)


def pure_literal_elimination(sat_instance):
    """
    Perform pure literal elimination on the given SAT instance.
    """
    print("[PLE] starting PLE")
    # find all the literals
    literals = set()
    for clause in sat_instance.clauses:
        for literal in clause:
            literals.add(literal)
    
    # find all the pure literals
    pure_literals = set()
    for literal in literals:
        if -literal not in literals:
            pure_literals.add(literal)
    
    print("[PLE] PLE pure literals found:", pure_literals)
    
    # remove all clauses containing the pure literals
    sat_instance.clauses = [clause for clause in sat_instance.clauses if not any(literal in clause for literal in pure_literals)]

    # assign the pure literals
    for literal in pure_literals:
        sat_instance.assignments[abs(literal)] = literal > 0
    
    print("[PLE] clauses after PLE:", sat_instance.clauses)

def check_done(sat_instance):
    """
    Check if the given SAT instance is solved.
    """
    if (len(sat_instance.clauses) == 0):
        return "done", True, sat_instance.assignments
    if any(len(clause) == 0 for clause in sat_instance.clauses):
        return "done", False, None
    
    return "continue", None, None


def solve(sat_instance):
    """
    Recursively solve the given SAT instance using the DPLL algorithm.
    """
    status, sat, assignments = check_done(sat_instance)
    if status == "done": return sat, assignments

    print("instance before unit prop", sat_instance)
    # Perform unit propagation
    unit_propagation(sat_instance)
    print("instance after unit prop", sat_instance)

    status, sat, assignments = check_done(sat_instance)
    if status == "done": return sat, assignments

    # Perform pure literal elimination
    pure_literal_elimination(sat_instance)

    status, sat, assignments = check_done(sat_instance)
    if status == "done": return sat, assignments

    # Choose a literal to assign
    literal = sat_instance.clauses[0].pop()
    sat_instance.clauses[0].add(literal)

    # Create a new SAT instance with the literal assigned to True
    sat_instance_true = copy.deepcopy(sat_instance)
    # sat_instance_true.assignments[abs(literal)] = literal > 0
    sat_instance_true.clauses.append({literal})

    # Create a new SAT instance with the literal assigned to False
    sat_instance_false = copy.deepcopy(sat_instance)
    # sat_instance_false.assignments[abs(literal)] = literal < 0
    sat_instance_false.clauses.append({-literal})


    # Recursively call DPLL on the new SAT instances
    print("branching on true for", literal)
    print("instance before branching", sat_instance_true)
    if solve(sat_instance_true)[0]:
        return True, sat_instance_true.assignments
    else:
        print("branching on false for", literal)
        return solve(sat_instance_false)