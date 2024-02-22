from dpll import solve
from dimacs import parse_cnf_file
from verify import verify_sat

# Run arguments
import argparse
parser = argparse.ArgumentParser(description="Solve a SAT instance using the DPLL algorithm.")
parser.add_argument("input_file", help="The input file containing the SAT instance in DIMACS format.")
args = parser.parse_args()

# Timer
import time

if __name__ == "__main__":
    sat_instance = parse_cnf_file(args.input_file)
    print(sat_instance)

    start_time = time.time()
    sat_status, assignments = solve(sat_instance)
    end_time = time.time()

    print()
    output = {}
    output["Instance"] = args.input_file.split("/")[-1]
    output["Result"] = "SAT" if sat_status else "UNSAT"
    output["Time"] = round(end_time - start_time, 2)

    if sat_status:
        # fill in any missing assignments with True defualt
        for variable in sat_instance.variables:
            if variable not in assignments:
                assignments[variable] = False
        
        # transform assignments to a string
        output["Solution"] = (" ".join([f"{k} {v}" for k, v in assignments.items()])).lower()

        # verify SAT
        verified = verify_sat(sat_instance, assignments)
        print("Verified:", verified)
    
    print(output)
    

    
    