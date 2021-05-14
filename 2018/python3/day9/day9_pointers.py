# Usage: python day9.py <n-players> <last-marble-points>
#
# Advent of Code 2018 - Day 9
#
# Here we use python lists as pointers to implement a circular doubly linked-list.

from sys import argv

NPLAYERS = int(argv[1])
NTURNS = int(argv[2])  # equivalent to last marble points


# Naming for implementation of doubly linked-list
VAL = 0
LEFT = 1
RIGHT = 2

class Rotli:
    """Doubly linked-list that wraps around"""
    def __init__(self):
        self.nplayers = NPLAYERS
        self.scores = [0] * self.nplayers
        self.curval = 0
        self.curptr = [0, None, None]
        self.curptr[LEFT] = self.curptr
        self.curptr[RIGHT] = self.curptr

    def curplayer(self):
        return (self.curval - 1) % self.nplayers + 1

    def insert(self):
        # Next marble to insert
        self.curval = self.curval + 1

        if self.curval % 23 == 0:
            self.take()
        else:
            self.skip()

    def skip(self):
        elem = [self.curval, None, None]

        # Where to insert it
        left, right = self.curptr[RIGHT], self.curptr[RIGHT][RIGHT]

        # Insert it, update links
        elem[LEFT] = left
        elem[RIGHT] = right
        left[RIGHT] = elem
        right[LEFT] = elem

        # Update current marble
        self.curptr = elem

    def take(self):
        # Go to marble to remove
        cur = self.curptr
        for _ in range(7):
            cur = cur[LEFT]

        # Remove by updating links
        cur[LEFT][RIGHT] = cur[RIGHT]
        cur[RIGHT][LEFT] = cur[LEFT]

        # Update current marble
        self.curptr = cur[RIGHT]

        # Update score
        self.scores[self.curplayer() - 1] += cur[VAL] + self.curval

    def __repr__(self):
        cur = self.curptr
        first = 0

        while cur[VAL] != first:  # rewind until marble 0
            cur = cur[RIGHT]

        res = ""
        dowhile = True
        wrapped = False
        while dowhile or not wrapped:
            dowhile = False  # simulates a "do while" loop

            if cur is self.curptr:
                res += "*"
            res += f"{cur[VAL]} "

            cur = cur[RIGHT]

            if cur[VAL] == first:
                wrapped = True

        return res.rstrip()


if __name__ == '__main__':
    r = Rotli()
    assert repr(r) == "*0"
    #: ->0 = [val: 0, left: ->0, right: ->0]

    r.insert()
    assert repr(r) == "0 *1"
    #: ->0 = [val: 0, left: ->1, right: ->1]
    #: ->1 = [val: 1, left: ->0, right: ->1]

    r.insert()
    assert repr(r) == "0 *2 1"
    #: ->0 = [val: 0, left: ->1, right: ->2]
    #: ->2 = [val: 2, left: ->0, right: ->1]
    #: ->1 = [val: 1, left: ->2, right: ->0]

    for tt in range(3, NTURNS + 1):
        r.insert()

    print(max(r.scores))
