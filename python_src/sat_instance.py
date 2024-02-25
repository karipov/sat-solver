import numpy as np

class SatInstance:
    def __init__(self, num_vars, clauses):
        self.num_vars = num_vars
        self.clauses = clauses
    
    def __str__(self):
        return f"SatInstance(num_vars={self.num_vars}, num_clauses={len(self.clauses)})"
    
    @staticmethod
    def from_dimacs(filename):
        # read the file lines
        with open(filename, "r") as f:
            lines = f.readlines()
        
        # parse the lines
        clauses = []
        for line in lines:
            # skip comments and problem line
            if line.startswith("c") or line.startswith("p"):
                continue
            # skip if line is empty
            if not line.strip():
                continue
            if line.strip() == "%" or line.strip() == "0":
                continue
            clause = [int(x) for x in line.split() if x != "0"]
            clauses.append(clause)

        # turn clauses into a numpy array
        max_clause_len = len(max(clauses, key=len))
        padded_clauses = [clause + [0] * (max_clause_len - len(clause)) for clause in clauses]
        np_clauses = np.array(padded_clauses, dtype=int)

        # TODO: remove the rows that only contain zeros ???
        np_clauses = np_clauses[~np.all(np_clauses == 0, axis=1)]

        # calculate number of variables
        num_vars = np.max(np.abs(np_clauses))

        return SatInstance(num_vars, np_clauses)