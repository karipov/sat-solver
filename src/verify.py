def verify_sat(sat_instance, assignments):
    """
    Verify the given assignments for the given SAT instance.
    """
    for clause in sat_instance.clauses:
        if not any(assignments[abs(literal)] == (literal > 0) for literal in clause):
            return False

    return True