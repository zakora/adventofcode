use std::env;


#[derive(Copy, Clone, Debug)]
struct Marble {
    num: usize,
    left: Option<usize>,
    right: Option<usize>
}


enum Dir {
    Left,
    Right
}

fn step(dir: Dir, mut cur: usize, marbles: &[Marble], n: u32) -> usize {
    for _ in 0..n {
        cur = match dir {
            Dir::Left => marbles[cur].left.unwrap(),
            Dir::Right => marbles[cur].right.unwrap()
        };
    }
    cur
}

fn insert_before(marble: usize, cur: usize, marbles: &mut[Marble]) -> usize {
    marbles[marble].left = marbles[cur].left;
    marbles[marble].right = Some(cur);
    let left = marbles[cur].left.unwrap();
    marbles[left].right = Some(marble);
    marbles[cur].left = Some(marble);

    marble
}

fn take(marble: usize, marbles: &mut[Marble]) -> usize {
    let marble_left = marbles[marble].left.unwrap();
    let marble_right = marbles[marble].right.unwrap();
    marbles[marble_left].right = marbles[marble].right;
    marbles[marble_right].left = marbles[marble].left;
    marbles[marble].left = None;
    marbles[marble].right = None;

    marble_right
}

fn status(cur: usize, marbles: &[Marble]) {
    // Marble 0 should be the left-most one
    let mut at: usize = 0;
    loop {
        if at == cur {
            print!("({}) ", cur);
        } else {
            print!("{} ", at);
        }
        at = marbles[at].right.unwrap();
        if at == 0 {
            break
        }
    }
    println!();
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let nplayers: usize = args[1].parse().unwrap();
    let nturns: usize = args[2].parse().unwrap();
    let nmarbles: usize = nturns + 1;


    // Pre-init with unlinked marbles
    let uninit = Marble {
        num: 0,
        left: None,
        right: None
    };
    let mut marbles = vec![uninit; nmarbles];
    let mut scores = vec![0; nplayers];

    // Init all marbles
    for num in 0..nmarbles {
        marbles[num] = Marble { num: num, left: None, right: None };
    }

    // Init game state for turn 0
    let mut cur: usize = 0;  // current active marble
    marbles[cur].left = Some(0);
    marbles[cur].right = Some(0);

    // Do the turns
    for marble_num in 1..nturns {
        if marble_num % 23 == 0 {
            let scored_marble = step(Dir::Left, cur, &marbles, 7);
            cur = take(scored_marble, &mut marbles);
            let player = marble_num % nplayers;
            scores[player] += scored_marble + marble_num;
        } else {
            let right_marble = step(Dir::Right, cur, &marbles, 2);
            cur = insert_before(marble_num, right_marble, &mut marbles);
        }
    }
    println!("{}", scores.iter().max().unwrap());
}
