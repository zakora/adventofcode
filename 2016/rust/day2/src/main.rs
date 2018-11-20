use std::io::{self, Read};

fn domovea(position: i32, dir: char) -> i32 {
    match (position, dir) {
        (1, 'U') => 1,
        (1, 'L') => 1,
        (1, 'D') => 4,
        (1, 'R') => 2,

        (2, 'U') => 2,
        (2, 'L') => 1,
        (2, 'D') => 5,
        (2, 'R') => 3,

        (3, 'U') => 3,
        (3, 'L') => 2,
        (3, 'D') => 6,
        (3, 'R') => 3,

        (4, 'U') => 1,
        (4, 'L') => 4,
        (4, 'D') => 7,
        (4, 'R') => 5,

        (5, 'U') => 2,
        (5, 'L') => 4,
        (5, 'D') => 8,
        (5, 'R') => 6,

        (6, 'U') => 3,
        (6, 'L') => 5,
        (6, 'D') => 9,
        (6, 'R') => 6,

        (7, 'U') => 4,
        (7, 'L') => 7,
        (7, 'D') => 7,
        (7, 'R') => 8,

        (8, 'U') => 5,
        (8, 'L') => 7,
        (8, 'D') => 8,
        (8, 'R') => 9,

        (9, 'U') => 6,
        (9, 'L') => 8,
        (9, 'D') => 9,
        (9, 'R') => 9,

        (_, _) => panic!("got ({}, {})", position, dir),
    }
}


fn domoveb(position: char, dir: char) -> char {
    match (position, dir) {
        ('1', 'U') => '1',
        ('1', 'L') => '1',
        ('1', 'D') => '3',
        ('1', 'R') => '1',

        ('2', 'U') => '2',
        ('2', 'L') => '2',
        ('2', 'D') => '6',
        ('2', 'R') => '3',

        ('3', 'U') => '1',
        ('3', 'L') => '2',
        ('3', 'D') => '7',
        ('3', 'R') => '4',

        ('4', 'U') => '4',
        ('4', 'L') => '3',
        ('4', 'D') => '8',
        ('4', 'R') => '4',

        ('5', 'U') => '5',
        ('5', 'L') => '5',
        ('5', 'D') => '5',
        ('5', 'R') => '6',

        ('6', 'U') => '2',
        ('6', 'L') => '5',
        ('6', 'D') => 'A',
        ('6', 'R') => '7',

        ('7', 'U') => '3',
        ('7', 'L') => '6',
        ('7', 'D') => 'B',
        ('7', 'R') => '8',

        ('8', 'U') => '4',
        ('8', 'L') => '7',
        ('8', 'D') => 'C',
        ('8', 'R') => '9',

        ('9', 'U') => '9',
        ('9', 'L') => '8',
        ('9', 'D') => '9',
        ('9', 'R') => '9',

        ('A', 'U') => '6',
        ('A', 'L') => 'A',
        ('A', 'D') => 'A',
        ('A', 'R') => 'B',

        ('B', 'U') => '7',
        ('B', 'L') => 'A',
        ('B', 'D') => 'D',
        ('B', 'R') => 'C',

        ('C', 'U') => '8',
        ('C', 'L') => 'B',
        ('C', 'D') => 'C',
        ('C', 'R') => 'C',

        ('D', 'U') => 'B',
        ('D', 'L') => 'D',
        ('D', 'D') => 'D',
        ('D', 'R') => 'D',

        (_, _) => panic!("unexpected (position, dir): ({}, {})", position, dir),
    }
}

fn main() {
    let mut buffer = String::new();
    io::stdin().read_to_string(&mut buffer).expect("failed to read from stdin");
    buffer.pop().expect("failed to pop trailing new line in buffer");

    let mut positiona = 5;
    let mut sola = String::new();

    let mut positionb = '5';
    let mut solb = String::new();

    for seq in buffer.lines() {
        for cc in seq.chars() {
            positiona = domovea(positiona, cc);
            positionb = domoveb(positionb, cc);
        }
        sola.push_str(&positiona.to_string());
        solb.push_str(&positionb.to_string());
    }
    println!("qa: {}", sola);
    println!("qb: {}", solb);
}
