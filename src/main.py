from dpll import solve
from dimacs import parse_cnf_file
from verify import verify_sat

# Run arguments
import argparse
parser = argparse.ArgumentParser(description="Solve a SAT instance using the DPLL algorithm.")
parser.add_argument("input_file", help="The input file containing the SAT instance in DIMACS format.")
args = parser.parse_args()

if __name__ == "__main__":
    sat_instance = parse_cnf_file(args.input_file)
    print(sat_instance)

    sat_status, assignments = solve(sat_instance)

    print()
    if sat_status:
        # fill in any missing assignments with True defualt
        for variable in sat_instance.variables:
            if variable not in assignments:
                assignments[variable] = True

        # print SAT
        print("SAT")
        print("Assignments:", assignments)

        # verify SAT
        verified = verify_sat(sat_instance, assignments)
        print("Verified:", verified)
    else:
        print("UNSAT")
    

    
    