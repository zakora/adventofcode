getinput = input()

def main():
    res = []
    inp = list(str(getinput))
    length = len(inp)
    half = length/2

    for i, _ in enumerate(inp):
        nexti = int((i + half) % length)
        if inp[i] == inp[nexti]:
            res.append(int(inp[i]))
    return sum(res)


print(main())
