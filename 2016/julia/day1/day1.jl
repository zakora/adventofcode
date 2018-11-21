function main(x, y, dir, moves)
    found_place = false
    known_places = Set([[x, y]])

    for move in moves
        turn = move[1]
        steps = parse(Int32, move[2:end])

        if     dir == 'N' && turn == 'L'
            dir = 'W'
        elseif dir == 'N' && turn == 'R'
            dir = 'E'
        elseif dir == 'W' && turn == 'L'
            dir = 'S'
        elseif dir == 'W' && turn == 'R'
            dir = 'N'
        elseif dir == 'S' && turn == 'L'
            dir = 'E'
        elseif dir == 'S' && turn == 'R'
            dir = 'W'
        elseif dir == 'E' && turn == 'L'
            dir = 'N'
        elseif dir == 'E' && turn == 'R'
            dir = 'S'
        end

        for _ in 1:steps
            if     (dir == 'N')
                y += 1
            elseif (dir == 'W')
                x -= 1
            elseif (dir == 'S')
                y -= 1
            elseif (dir == 'E')
                x += 1
            end

            current_place = [x, y]
            if !found_place && current_place in known_places
                found_place = true
                println("qb: ", abs(x) + abs(y))
            end

            known_places = union(known_places, Set([current_place]))
        end
    end

    println("qa: ", abs(x) + abs(y))
end

content = strip(read(stdin, String))
moves = split(content, ", ")
main(0, 0, 'N', moves)
