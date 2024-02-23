def verify_sat(sat_instance, assignments):
    """
    Verify the given assignments for the given SAT instance.
    """
    for clause in sat_instance.clauses:
        # Initialize a flag to check if the current clause is satisfied
        clause_satisfied = False

        for literal in clause:
            # Extract the literal index and its expected truth value based on the sign
            literal_index = abs(literal) - 1
            expected_truth = literal > 0

            # Check if the current literal is satisfied by the assignment
            if assignments[literal_index] == expected_truth:
                clause_satisfied = True
                break
        
        if not clause_satisfied:
            return False
    
    return True

        