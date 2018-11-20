moves = input().split(',')
init_progs = "abcdefghijklmnop"

def dance(moves, progs):
    for m in moves:
        if m[0] == "s":
            size = int(m[1:])
            progs = progs[-size:] + progs[:-size]
        elif m[0] == "x":
            [posa, posb] = map(int, m[1:].split("/"))
            tmp = list(progs)
            a = progs[posa]
            b = progs[posb]
            tmp[posa] = b
            tmp[posb] = a
            progs = "".join(tmp)
        elif m[0] == "p":
            [a, b] = m[1:].split("/")
            posa = progs.find(a)
            posb = progs.find(b)
            tmp = list(progs)
            tmp[posa] = b
            tmp[posb] = a
            progs = "".join(tmp)

    mapping = {}
    for i, c in enumerate(list(init_progs)):
        mapping[c] = i

    permut = []
    for c in list(progs):
        permut.append(mapping[c])

    return (progs, permut)

def megadance(moves, progs, n):
    _, permut = dance(moves, progs)
    while n > 0:
        if n % 100000 == 0:
            print(n)
        new_progs = []
        for idx in permut:
            new_progs.append(progs[idx])
        progs = new_progs
        n = n - 1
    return "".join(progs)

# print(dance(moves, init_progs))
print(megadance(moves, init_progs, 100000000))
