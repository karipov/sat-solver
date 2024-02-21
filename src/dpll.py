
def unit_propagation(sat_instance):
    """
    Perform unit propagation on the given SAT instance.

    Args:
        sat_instance (SATInstance): The SAT instance to perform unit propagation on.

    Returns:
        None
    """
    units = []

    # find all the unit clauses
    for clause in sat_instance.clauses:
        if len(clause) == 1:
            units.append(clause.pop())
    
    # remove all clauses containing the units
    sat_instance.clauses = [clause for clause in sat_instance.clauses if not any(unit in clause for unit in units)]
    
    # remove all instances of the negation of the unit from all clauses
    for i in range(sat_instance.clauses):
        sat_instance.clauses[i] = [literal for literal in sat_instance.clauses[i] if -literal not in units]
    
    # assign the units
    for unit in units:
        sat_instance.assignments[abs(unit)] = unit > 0


def pure_literal_elimination(sat_instance):
    """
    Perform pure literal elimination on the given SAT instance.

    Args:
        sat_instance (SATInstance): The SAT instance to perform pure literal elimination on.
    
    Returns:
        None
    """
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
    
    # remove all clauses containing the pure literals
    sat_instance.clauses = [clause for clause in sat_instance.clauses if not any(literal in clause for literal in pure_literals)]

    # assign the pure literals
    for literal in pure_literals:
        sat_instance.assignments[abs(literal)] = literal > 0


def dpll(sat_instance):
    # if there are no clauses left, we are SAT
    if len(sat_instance.clauses) == 0:
        return True
    
    # TODO: if any clause is empty, we are UNSAT, so backtrack
    if any(len(clause) == 0 for clause in sat_instance.clauses):
        return False


def main():
    pass


if __name__ == "__main__":
    main()