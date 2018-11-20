use std::collections::HashSet;
use std::io::{self, Read};
use std::str::FromStr;

#[derive(Debug)]
enum Orient {
    North,
    West,
    South,
    East,
}

#[derive(PartialEq, Eq, Hash, Clone)]
struct Pos {
    x: i32,
    y: i32,
}

impl Pos {
    fn abs(&self) -> i32 {
        self.x.abs() + self.y.abs()
    }
}

fn main() {
    // state initialization
    let mut position = Pos{x: 0, y: 0};
    let mut orient = Orient::North;

    // state for the moves
    let mut turn: char;
    let mut steps: i32;
    let mut places = HashSet::new();
    let mut found_before = false;
    places.insert(position.clone());

    // parse the input
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    buffer
        .pop() // remove trailing new line
        .expect("failed to pop \\n");

    // make computations for each move
    for mm in buffer.split(", ") {
        turn = char::from_str(&mm[0..1]).expect("failed to parse turn");
        steps = i32::from_str(&mm[1..]).expect("failed to parse steps");

        // apply direction
        match (&orient, turn) {
            (Orient::North, 'L') => orient = Orient::West,
            (Orient::North, 'R') => orient = Orient::East,
            (Orient::West, 'L') => orient = Orient::South,
            (Orient::West, 'R') => orient = Orient::North,
            (Orient::South, 'L') => orient = Orient::East,
            (Orient::South, 'R') => orient = Orient::West,
            (Orient::East, 'L') => orient = Orient::North,
            (Orient::East, 'R') => orient = Orient::South,
            (_, _) => panic!("Tried to turn {}", turn),
        }

        // move the current position, and add it to places
        for _ in 1..steps + 1 {
            match &orient {
                Orient::North => position.y += 1,
                Orient::West => position.x -= 1,
                Orient::South => position.y -= 1,
                Orient::East => position.x += 1,
            }

            if !found_before && places.contains(&position) {
                println!("qb: {}", position.abs());
                found_before = true;
            }
            else {
                places.insert(position.clone());
            }
        }
    }

    println!("qa: {}", position.abs());
}
