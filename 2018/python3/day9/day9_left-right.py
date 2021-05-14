# Usage: python day9.py <n-players> <last-marble-points>
#
# Advent of code 2018 - Day 9
#
# This version doesn't use Python lists as pointers.
# It still represents a circular doubly linked-list, but with a different data structure:
# - "left" list
# - "right" list
# The values of this list are NOT in the order of the marble circle.
# Rather, "left" keeps track for each marble (list index) what other marble is on its left.
# Same for "right".

from sys import argv

NPLAYERS = int(argv[1])
NMARBLES = int(argv[2])


def main():
    cur, left, right = init()
    scores = [0] * NPLAYERS

    for cmarble in range(1, NMARBLES):
        player = (cmarble - 1) % NPLAYERS
        cur = turn(cmarble, cur, left, right, player, scores)
        # status(cur, right)

    print(max(scores))


def init():
    left = [None] * (NMARBLES + 1)  # +1 since list from [0 to N]
    right = [None] * (NMARBLES + 1)

    cur = 0
    left[0] = 0
    right[0] = 0

    return cur, left, right


def turn(cmarble, cur, left, right, player, scores):
    if cmarble % 23 == 0:
        marble = step(cur, left, 7)
        cur = remove(marble, left, right)
        scores[player] += marble + cmarble
    else:
        insert_left_of = step(cur, right, 2)
        cur = insert_left(cmarble, insert_left_of, left, right)

    return cur


def remove(marble, left, right):
    mleft = left[marble]
    mright = right[marble]
    right[mleft] = mright
    left[mright] = mleft
    right[marble] = None
    left[marble] = None

    return mright


def step(cur, direct, n):
    for _ in range(n):
        cur = direct[cur]
    return cur


def insert_left(marble, cur, left, right):
    mleft = left[cur]
    mright = cur
    left[marble] = mleft
    right[marble] = mright
    left[mright] = marble
    right[mleft] = marble

    return marble
    

def status(cur, right):
    # Warning: no integrity check, "left" list could be wrong even when this output is correct.
    cinit = 0
    ccur = cinit
    while True:
        if ccur == cur:
            print(f"({cur})", end=" ")
        else:
            print(ccur, end=" ")

        ccur = right[ccur]
        if ccur == cinit:
            break
    print()


if __name__ == "__main__":
    main()
