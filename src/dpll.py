import numpy as np
from sat_instance import SatInstance
from optimizations import jeroslow_wang, choose_random
import numba

import logging

def find_units(sat_instance) -> np.ndarray:
    """
    Find all unit clauses in the given SAT instance.
    """
    # find all rows with exactly one nonzero element
    rows_with_one_nonzero = np.count_nonzero(sat_instance.clauses, axis=1) == 1

    # find all nonzero elements
    non_zero_elements_mask = sat_instance.clauses != 0

    # combine the two masks to find the non-zero elements in rows
    # with exactly one non-zero value -- aka extract the unit literal
    mask = non_zero_elements_mask & rows_with_one_nonzero[:, np.newaxis]

    output = sat_instance.clauses[mask]
    assert len(output.shape) == 1 # make sure the output is a 1D array

    return output


def unit_propagation(sat_instance, units, assignments):
    """
    Perform unit propagation on the given SAT instance.
    """
    for literal in units:
        # update the assignment of the unit
        assignments[abs(literal) - 1] = int(literal > 0)

        # remove the rows that contain the literal
        row_mask = (sat_instance.clauses == literal).any(axis=1)
        sat_instance.clauses = sat_instance.clauses[~row_mask]

        # set all instances of the opposite of the literal to 0
        neg_mask = sat_instance.clauses == -literal
        sat_instance.clauses[neg_mask] = 0
    
    # check if there are any new unit clauses
    # if so, keep doing unit propagation
    # TODO: should the output be the sat_instance or is it modified in-place?
    new_units = find_units(sat_instance)
    if len(new_units) > 0:
        unit_propagation(sat_instance, new_units, assignments)


def find_pure_literals(sat_instance) -> np.ndarray:
    """
    Find all pure literals in the given SAT instance.
    """
    pure_literals = []

    # for each variable
    for i in range(sat_instance.num_vars):
        positive = i + 1
        negative = -(i + 1)
        pos_occur = np.isin(positive, sat_instance.clauses)
        neg_occur = np.isin(negative, sat_instance.clauses)

        # check if the positive literal is pure
        if (pos_occur) and (not neg_occur):
            pure_literals.append(positive)
        # check if the negative literal is pure
        elif (not pos_occur) and (neg_occur):
            pure_literals.append(negative)
    
    return np.array(pure_literals)


def pure_literal_elimination(sat_instance, pure_literals, assignments):
    """
    Perform pure literal elimination on the given SAT instance.
    """
    for literal in pure_literals:
        # update the assignment of the pure literal
        assignments[abs(literal) - 1] = int(literal > 0)

        # delete all clauses containing the literal
        mask = (np.abs(sat_instance.clauses) == abs(literal)).any(axis=1)
        sat_instance.clauses = sat_instance.clauses[~mask]


def splitting_rule(sat_instance) -> np.ndarray:
    """
    Find the literal to split on for DPLL
    and return a new clause with that literal.
    """
    K_TOP_SORT = 3
    ALGORITHM = "random"

    chosen_literal = None
    if ALGORITHM == "top-k":
        # flatten and remove all zeros
        flat = sat_instance.clauses.flatten()
        flat = flat[flat != 0]

        # find the top K_TOP_SORT most common literals
        top_k = np.bincount(np.abs(flat)).argsort()[-K_TOP_SORT:][::-1]

        # randomly choose one of the top K_TOP_SORT most common literals
        chosen_literal = np.random.choice(top_k)
    elif ALGORITHM == "jw":
        # get the maximum scores for each variable in both phases
        pos_scores, neg_scores = jeroslow_wang(sat_instance)
        logging.info(f"pos_scores: {pos_scores}, neg_scores: {neg_scores}")
        max_pos_index = np.argmax(pos_scores)
        max_neg_index = np.argmax(neg_scores)

        # choose the literal with the highest score (whether positive or negative)
        chosen_literal = (max_pos_index + 1) if pos_scores[max_pos_index] > neg_scores[max_neg_index] else -(max_neg_index + 1)
        chosen_literal += 1
    elif ALGORITHM == "random":
        chosen_literal = choose_random(sat_instance)

    # create a new clause with the chosen literal
    new_clause = np.zeros(sat_instance.clauses.shape[1], dtype=int)
    new_clause[0] = chosen_literal

    return new_clause


def check_empty_clause(sat_instance):
    """
    Check if the given SAT instance contains an empty clause.
    """
    return np.any(np.all(sat_instance.clauses == 0, axis=1))


def check_no_clauses(sat_instance):
    """
    Check if the given SAT instance contains no clauses.
    """
    return len(sat_instance.clauses) == 0


def solve(sat_instance, assignments) -> bool:
    """
    Recursively solve the given SAT instance using the DPLL algorithm.
    """
    logging.debug(f"Current clauses:\n{sat_instance.clauses}")

    # check base cases
    if check_empty_clause(sat_instance):
        logging.info("conflict detected")
        return False
    if check_no_clauses(sat_instance):
        return True
    
    # find unit clauses and do unit propagation
    units = find_units(sat_instance)
    if len(units) > 0:
        logging.info(f"unit clauses found: {units}")
        unit_propagation(sat_instance, units, assignments)
        # recurse again to make sure we don't have any units left
        return solve(sat_instance, assignments)

    # find pure literals and do pure literal elimination
    pure_literals = find_pure_literals(sat_instance)
    if len(pure_literals) > 0:
        logging.info(f"pure literals found: {pure_literals}")
        pure_literal_elimination(sat_instance, pure_literals, assignments)
        return solve(sat_instance, assignments)

    # if we haven't returned yet, we need to DPLL split
    new_clause = splitting_rule(sat_instance)

    # TODO: will assignments be modified in-place or should we make a copy?
    # try with the new positive clause
    pos_sat_instance = SatInstance(
        sat_instance.num_vars,
        np.vstack([sat_instance.clauses, new_clause])
    )
    if solve(pos_sat_instance, assignments):
        return True
    else:
        # try with the negated new clause
        neg_sat_instance = SatInstance(
            sat_instance.num_vars,
            np.vstack([sat_instance.clauses, -new_clause])
        )
        return solve(neg_sat_instance, assignments)

    