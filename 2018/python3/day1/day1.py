from itertools import cycle
from sys import stdin

def qb(freqs):
    freq = 0
    known_freqs = set([freq])
    for fchange in cycle(freqs):
        freq += fchange
        if freq in known_freqs:
            return freq
        else:
            known_freqs.add(freq)

if __name__ == '__main__':
    freqs = list(map(lambda line: int(line.strip()), stdin.readlines()))
    print(f"qa: {sum(freqs)}")

    print("qb: {}".format(qb(freqs)))
