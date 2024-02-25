import numpy as np

def jeroslow_wang(sat_instance) -> tuple[np.ndarray, np.ndarray]:
    """
    Calculate the Jeroslow-Wang heuristic for each variable in the given SAT instance.
    """
    pos_scores = np.zeros(sat_instance.num_vars, dtype=float)
    neg_scores = np.zeros(sat_instance.num_vars, dtype=float)

    # calculate the score for each variable
    for literal in range(1, sat_instance.num_vars + 1):
        # find rows containing the target literal
        rows_with_pos_literal = sat_instance.clauses[np.any(sat_instance.clauses == literal, axis=1)]
        rows_with_neg_literal = sat_instance.clauses[np.any(sat_instance.clauses == -literal, axis=1)]

        # count the length of the rows containing the target literal
        pos_literal_count = np.count_nonzero(rows_with_pos_literal, axis=1)
        neg_literal_count = np.count_nonzero(rows_with_neg_literal, axis=1)

        assert pos_literal_count.ndim == 1
        assert neg_literal_count.ndim == 1

        # calculate the score for the target literal
        pos_score = np.sum(np.power(2, pos_literal_count))
        neg_score = np.sum(np.power(2, neg_literal_count))

        pos_scores[literal - 1] = pos_score
        neg_scores[literal - 1] = neg_score

    return pos_scores, neg_scores

def choose_random(sat_instance) -> int:
    """
    Choose a random literal to split on.
    """
    flatten = sat_instance.clauses.ravel()
    return np.random.choice(flatten[flatten != 0])