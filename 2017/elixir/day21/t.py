from sys import argv
from typing import Iterator

import numpy as np


STARTING_PATTERN = np.array(
    [[False, True, False],
     [False, False, True],
     [True, True, True]])


def main(filename: str, niter: int) -> int:
    # Uses vsplit and hsplit to get blocks, vstack and hstack to set blocks
    rules = parse(filename)
    pattern = STARTING_PATTERN
    for _ in range(niter):
        (size, _) = pattern.shape
        pattern_size = 2 if size % 2 == 0 else 3
        splits = size / pattern_size

        new_pattern = []
        for row in np.vsplit(pattern, splits):
            new_row = []
            for block in np.hsplit(row, splits):
                enhanced_block = rules[to_tuple(block)]
                new_row.append(enhanced_block)
            new_pattern.append(np.hstack(new_row))
        pattern = np.vstack(new_pattern)
    return np.count_nonzero(pattern)


def main_bis(filename: str, niter: int) -> int:
    # Uses numpy view to get and set blocks
    rules = parse(filename)
    sizes = list(compute_size(niter))
    (_, final_size) = sizes[-1]

    pattern = np.empty((final_size, final_size), dtype=bool)
    pattern[:3, :3] = STARTING_PATTERN
    next_pattern = np.empty((final_size, final_size), dtype=bool)

    for (csize, total_size) in sizes[:-1]:
        nsize = 3 if csize == 2 else 4
        for (cx, cy), (nx, ny) in coordinates(total_size):
            block = pattern[cx:cx+csize, cy:cy+csize]
            enhanced_block = rules[to_tuple(block)]
            next_pattern[nx:nx+nsize, ny:ny+nsize] = enhanced_block
        (pattern, next_pattern) = (next_pattern, pattern)

    return np.count_nonzero(pattern)


def compute_size(niter: int) -> Iterator:
    size = 3
    for _ in range(niter + 1):
        block_size = 2 if size % 2 == 0 else 3
        yield block_size, size
        nblocks = int(size / block_size)
        size = nblocks * (3 if size % 2 == 0 else 4)


def coordinates(size: int) -> Iterator:
    csize = 2 if size % 2 == 0 else 3
    nsize = 3 if csize == 2 else 4
    nblocks = int(size / csize)
    for xblock in range(nblocks):
        for yblock in range(nblocks):
            cx = xblock * csize
            cy = yblock * csize
            nx = xblock * nsize
            ny = yblock * nsize
            yield (cx, cy), (nx, ny)

def parse(filename: str) -> dict:
    res = {}
    with open(filename) as f:
        lines = f.readlines()

    for line in lines:
        [left, right] = line.strip().split(" => ")
        pattern_left = to_square(left)
        pattern_right = to_square(right)

        for v in variations(pattern_left):
            res[to_tuple(v)] = pattern_right

    return res


def to_square(pattern: str) -> np.array:
    res = np.array([list(line) for line in pattern.split("/")])
    return res == "#"


def to_tuple(array: np.array) -> tuple:
    res = []
    for row in array:
        res.append(tuple(row))
    return tuple(res)


def variations(array: np.array) -> Iterator[np.array]:
    for k in range(4):
        rot = np.rot90(array, k=k)
        yield rot
        yield np.fliplr(rot)
        yield np.flipud(rot)


if __name__ == '__main__':
    print(main_bis(argv[1], int(argv[2])))
