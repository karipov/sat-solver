from sat_instance import SATInstance

def parse_cnf_file(file_name):
    sat_instance = None

    try:
        with open(file_name, 'r') as file:
            # Skip comment lines
            line = next(line for line in file if not line.startswith('c'))

            # Check for the problem line
            tokens = line.split()
            if tokens[0] != 'p' or tokens[1] != 'cnf':
                raise ValueError("Error: DIMACS file does not have proper problem line or format is not CNF")

            num_vars = int(tokens[2])
            num_clauses = int(tokens[3])
            sat_instance = SATInstance(num_vars, num_clauses)

            # Parse clauses
            clause = set()
            for line in file:
                if line.startswith('c'):
                    continue

                tokens = line.split()
                if tokens[-1] != '0':
                    raise ValueError(f"Error: clause line does not end with 0 {tokens}")

                for token in tokens[:-1]:
                    if token:
                        literal = int(token)
                        clause.add(literal)
                        sat_instance.add_variable(literal)

                sat_instance.add_clause(clause)
                clause = set()

    except FileNotFoundError:
        raise FileNotFoundError(f"Error: DIMACS file is not found {file_name}")

    return sat_instance

if __name__ == "__main__":
    sat_instance = parse_cnf_file("toy_simple.cnf")
    print(sat_instance.num_vars)
    print(sat_instance.num_clauses)
    print(sat_instance.variables)
    print(sat_instance.clauses)

