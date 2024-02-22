class SATInstance:
    def __init__(self, num_vars, num_clauses):
        self.num_vars = num_vars
        self.num_clauses = num_clauses
        self.variables = set()
        self.assignments = dict()
        self.clauses = []
    
    def __str__(self):
        out = "SAT Instance:\n" \
              + f"Number of variables: {self.num_vars}\n" \
              + f"Number of clauses: {self.num_clauses}\n" \
              + f"Variables: {self.variables}\nClauses: {self.clauses}\n" \
              + f"Current assignments: {self.assignments}\n\n"
        return out

    def add_variable(self, variable):
        self.variables.add(abs(variable))

    def add_clause(self, clause):
        self.clauses.append(clause)