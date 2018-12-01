import math
import sequtils
import sets
import strutils

proc parse_freq_change(s: string): int =
  let
    sign = if s[0] == '+': 1
           else: -1
    number = parseInt(s[1 .. s.high])
    
  sign * number

proc qb(freqs: seq[int]): int =
  var
    fchange: int
    freq = 0
    index = 0
    length = freqs.high + 1
    found = false
    known_freqs = toSet([freq])

  while not found:
    fchange = freqs[index]
    freq += fchange
    if known_freqs.contains(freq):
      found = true
    else:
      index = (index + 1).mod(length)
      known_freqs.incl(freq)

  freq

var freqs = readAll(stdin).strip().splitLines().map(parse_freq_change)
echo("qa: ", freqs.sum())
echo("qb: ", qb(freqs))
