from collections import defaultdict
from sys import stdin


def count_letters(boxid):
    res = defaultdict(lambda: 0)
    for letter in boxid:
        res[letter] += 1
    return res

def has_ntuple(boxid, n):
    """Returns true if at least a tuple 'n' letters in the box ID"""
    counts = count_letters(boxid)
    return any(map(lambda cnt: cnt == n, counts.values()))

def has_pair(boxid):
    return has_ntuple(boxid, 2)

def has_triple(boxid):
    return has_ntuple(boxid, 3)

def qa(boxids):
    npairs = len(list(filter(has_pair, boxids)))
    ntriples = len(list(filter(has_triple, boxids)))
    return npairs * ntriples


def differ_one_char(a, b):
    res = ""
    diff = 0
    for cha, chb in zip(a, b):
        if cha != chb:
            diff += 1
        else:
            res += cha
    return (diff == 1, res)

def qb(boxids):
    for idx, boxid in enumerate(boxids):
        for cmp_boxid in boxids[idx + 1 : -1]:
            (is_match, extract) = differ_one_char(boxid, cmp_boxid)
            if is_match:
                return extract

if __name__ == '__main__':
    boxids = list(map(lambda line: line.strip(), stdin.readlines()))
    print("qa: {}".format(qa(boxids)))
    print("qb: {}".format(qb(boxids)))
