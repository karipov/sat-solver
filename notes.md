
### DPLL
Basic DPLL pseudocode is the following (from CHAFF paper)

```cpp
while (true) {
    if (!decide()): // if no unassigned vars
        return SAT;

    while (!bcp()) {
        if (!resolveConflict())
        return UNSAT;
    }
}

bool resolveConflict() {
    d = most recent decision not ‘tried both ways’;

    if (d == NULL) // no such d was found
        return false;

    flip the value of d;
    mark d as tried both ways;
    undo any invalidated implications;

    return true;
}
```

### decide()
The `decide()` func selects a literal that is not currently assigned and gives it a value (true or false). We refer to this as a *decision*. As each new decision is made, we push these onto a decision stack which is associated with a decision level.

```cpp
bool decide() {
    use some heuristic to select variable
    check that variable is not yet assigned
    choose literal or -literal

    record decision on decision stack with decision level

    if no unassigned variables remain:
        return false;
    else:
        return true;
}
```

### bcp()
The `bcp()` func, which stands for boolean constraint propagation, is used when we want to identify what variables must be forced a certain assignment. This can happen through the *unit clause rule*, for example.

Since unit clauses force a variable assignment, we call these *implications*. Implications are not decisions. Instead, they are attributed to a decision made at some decision level.

bcp() is carried out recursively until there are no implications forced by the unit clause rule, in which we return True. A conflict can occur if a clause is not properly satisfied, then we return False.

```cpp
bool bcp(most_recent_assignment) {
    // given the most recent assignment, update the 2-watched literal watchlists
    
    if (conflict is found) {
        return false;
    }

    if unit clause is found {
        return bcp(with found unit literal);
    }

    // no more bcp implications
    return true;
}
```

### resolveConflict()
The `resolveConflict()` func undoes the implications generated on the most recent decision level, including the decision itself. 