#!/usr/bin/env python3

def main():
    # position
    x = 0
    y = 0
    orient = 'N'
    places = {(0, 0)}
    found_before = False

    # read stdin
    data = input()
    moves = data.split(", ")

    for mm in moves:
        turn = mm[0]
        steps = int(mm[1:])

        # apply turn
        if   turn == 'L' and orient == 'N':
            orient = 'W'
        elif turn == 'L' and orient == 'W':
            orient = 'S'
        elif turn == 'L' and orient == 'S':
            orient = 'E'
        elif turn == 'L' and orient == 'E':
            orient = 'N'
        elif turn == 'R' and orient == 'N':
            orient = 'E'
        elif turn == 'R' and orient == 'W':
            orient = 'N'
        elif turn == 'R' and orient == 'S':
            orient = 'W'
        elif turn == 'R' and orient == 'E':
            orient = 'S'

        # add places
        if not found_before:
            for ii in range(1, steps + 1):
                if orient == 'N':
                    new_place = (x, y + ii)
                elif orient == 'W':
                    new_place = (x - ii, y)
                elif orient == 'S':
                    new_place = (x, y - ii)
                elif orient == 'E':
                    new_place = (x + ii, y)

                # check if was here before
                if new_place in places:
                    print("qb:", abs(new_place[0]) + abs(new_place[1]))
                    found_before = True

                places.add(new_place)
            
        # apply steps
        if   orient == 'N':
            y += steps
        elif orient == 'W':
            x -= steps
        elif orient == 'S':
            y -= steps
        elif orient == 'E':
            x += steps

    print("qa:", abs(x) + abs(y))

if __name__ == '__main__':
    main()
