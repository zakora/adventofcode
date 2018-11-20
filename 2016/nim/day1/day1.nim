import sets
import strformat
import strutils

var
  moves = readAll(stdin).strip()
  dir = 'N'
  x = 0
  y = 0
  known_places = toSet([[0, 0]])
  current_place = [0, 0]
  found_place = false
  turn: char
  steps: int

for move in moves.split(", "):
  turn = move[0]
  steps = parseInt(move[1 .. move.high])

  if   (dir, turn) == ('N', 'L'):
    dir = 'W'
  elif (dir, turn) == ('N', 'R'):
    dir = 'E'
  elif (dir, turn) == ('W', 'L'):
    dir = 'S'
  elif (dir, turn) == ('W', 'R'):
    dir = 'N'
  elif (dir, turn) == ('S', 'L'):
    dir = 'E'
  elif (dir, turn) == ('S', 'R'):
    dir = 'W'
  elif (dir, turn) == ('E', 'L'):
    dir = 'N'
  elif (dir, turn) == ('E', 'R'):
    dir = 'S'

  for _ in 1 .. steps:
    if   dir == 'N':
      y += 1
    elif dir == 'W':
      x -= 1
    elif dir == 'S':
      y -= 1
    elif dir == 'E':
      x += 1

    current_place = [x, y]
    if not found_place and known_places.contains(current_place):
      echo "qb: ", abs(x) + abs(y)
      found_place = true
    else:
      known_places.incl(current_place)

echo "qa: ", abs(x) + abs(y)
