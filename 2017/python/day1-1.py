getinput = input()

def main():
    # import pdb; pdb.set_trace()
    res = []
    split_input = list(str(getinput))
    for i, _ in enumerate(split_input):
        if i == len(split_input) - 1:
            if split_input[i] == split_input[-1]:
                res.append(int(split_input[i]))
        else:
            if split_input[i] == split_input[i + 1]:
                res.append(int(split_input[i]))
    return sum(res)

print(main())
