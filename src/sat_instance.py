class SATInstance:
    def __init__(self, num_vars, num_clauses):
        self.num_vars = num_vars
        self.num_clauses = num_clauses
        self.variables = set()
        self.assignments = dict()
        self.clauses = []

    def add_variable(self, variable):
        self.variables.add(abs(variable))

    def add_clause(self, clause):
        self.clauses.append(clause)