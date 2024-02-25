import argparse
import time
import logging
import sys

import numpy as np

from dpll import solve
from verify import verify_sat
from sat_instance import SatInstance

# Run arguments
parser = argparse.ArgumentParser(description="Solve a SAT instance using the DPLL algorithm.")
parser.add_argument("input_file", help="The input file containing the SAT instance in DIMACS format.")
args = parser.parse_args()

# logging
logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")


if __name__ == "__main__":
    # read the SAT instance from the input file
    sat_instance = SatInstance.from_dimacs(args.input_file)
    print(sat_instance)

    # initialize the assignments array
    # default sets to false
    assignments = np.zeros(sat_instance.num_vars, dtype=int)

    # solve the SAT instance with timer
    start_time = time.time()
    sat_status = solve(sat_instance, assignments)
    end_time = time.time()

    print(f"Time elapsed: {end_time - start_time:.3f}s")
    print(f"SAT status: {sat_status}")
    if not sat_status: sys.exit(1)

    # display and verify the assignments
    with np.printoptions(threshold=np.inf):
        print(f"Assignments: {assignments}")
    print(f"Verified: {verify_sat(sat_instance, assignments)}")
   

    
    