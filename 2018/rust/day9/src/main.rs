extern crate regex;

use regex::Regex;
use std::collections::HashMap;
use std::io::{self, Read};
use std::str::FromStr;

fn print_circle(idx: usize, circle: &Vec<u32>) {
    let mut res = String::new();
    for (ii, marble) in circle.iter().enumerate() {
        let fmt_marble = if ii == idx {
            format!("({})", marble)
        } else {
            format!("{}", marble)
        };
        res.push_str(&format!("{:^7}", fmt_marble));
    }
    println!("{}", res);
}

fn change_score(player: u32, marble: u32, idx: &mut i32, circle: &mut Vec<u32>, scores: &mut HashMap<u32, u32>) {
    /*
    1. add 'marble' to 'player' score
    2. idx -= 7
       score[player] += remove circle[idx]
     */
    let player_score = scores.entry(player).or_insert(0);
    *player_score += marble;

    *idx -= 7;
    if *idx < 0 {
        *idx += circle.len() as i32;
    }
    *player_score += circle.remove(*idx as usize);
}

fn qa(nplayer: u32, niter: u32) -> u32 {
    let mut circle = vec![0u32];
    let mut idx = 0;
    let mut scores = HashMap::new();

    for marble in 1..niter + 1 {
        if marble % 1000 == 0 {
            println!("marble: {}", marble);
        }
        let player = ((marble - 1) % nplayer) + 1;
        if marble % 23 == 0 {
            //print_circle(idx as usize, &circle);
            change_score(player, marble, &mut idx, &mut circle, &mut scores);
            //print_circle(idx as usize, &circle);
        } else {
            idx = ((idx + 1) % (circle.len() as i32)) + 1;
            circle.insert(idx as usize, marble);
        }
        print_circle(idx as usize, &circle);
    }
    
    *scores.values().max().expect("no score found")
}

#[test]
fn test_qa() {
    assert_eq!(qa(9, 25), 32);
    assert_eq!(qa(10, 1618), 8317);
    assert_eq!(qa(13, 7999), 146373);
    assert_eq!(qa(17, 1104), 2764);
    assert_eq!(qa(21, 6111), 54718);
    assert_eq!(qa(30, 5807), 37305);
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");

    let re = Regex::new(r"(\d+) players; last marble is worth (\d+) points")
        .expect("failed to create regex");
    let caps = re.captures(&buffer).expect("failed to match regex");
    let nplayer = u32::from_str(&caps[1]).expect("failed to cast nplayer to u32");
    let niter = u32::from_str(&caps[2]).expect("failed to cast niter to u32");

    println!("qa: {}", qa(nplayer, niter));
}
