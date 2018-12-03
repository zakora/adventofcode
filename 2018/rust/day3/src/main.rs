extern crate regex;

use regex::Regex;
use std::collections::{HashMap, HashSet};
use std::io::{self, Read};
use std::str::FromStr;

#[derive(PartialEq, Debug)]
struct Claim {
    id: u32,
    left: u32,
    top: u32,
    width: u32,
    height: u32,
}

fn parse(claim: &str) -> Claim {
    let re = Regex::new(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)").expect("failed to build regex");
    let caps = re.captures(claim).expect("failed regex capture");
    Claim {
        id: u32::from_str(&caps[1]).expect("failed to cast id"),
        left: u32::from_str(&caps[2]).expect("failed to cast left"),
        top: u32::from_str(&caps[3]).expect("failed to cast top"),
        width: u32::from_str(&caps[4]).expect("failed to cast width"),
        height: u32::from_str(&caps[5]).expect("failed to cast height"),
    }
}

#[test]
fn test_parse() {
    let input = String::from("#1 @ 2,3: 4x5");
    let c = Claim {
        id: 1,
        left: 2,
        top: 3,
        width: 4,
        height: 5,
    };
    assert_eq!(c, parse(&input));
}

/// Count how many overlaps are for each (x, y) — 1 meanning no overlap: only one cut present.
/// Return the claim id that has no overlap.
fn count_cuts(claims: &Vec<&str>, cuts: &mut HashMap<(u32, u32), (u32, u32)>) -> u32 {
    let mut set_ids = HashSet::new();
    for c in claims {
        let claim = parse(c);
        set_ids.insert(claim.id);
        
        for x in claim.left .. claim.left + claim.width {
            for y in claim.top .. claim.top + claim.height {
                // Check if an id is already present
                match cuts.get(&(x, y)) {
                    Some((_count, id)) => {
                        set_ids.remove(id);  // remove overlapped id
                        set_ids.remove(&claim.id); // remove overlapping id
                    },
                    None => ()
                }
                let count = cuts.entry((x, y)).or_insert((0, claim.id));
                (*count).0 += 1;
            }
        }
    }
    *set_ids.iter().next().unwrap()
}

fn qa(cuts: &HashMap<(u32, u32), (u32, u32)>) -> usize {
    cuts.values()
        .filter(|&(count, _id)| *count > 1)
        .count()
}

#[test]
fn test_qa_qb() {
    let input = String::from(
        "#1 @ 1,3: 4x4
         #2 @ 3,1: 4x4
         #3 @ 5,5: 2x2",
    );
    let parsed = input.lines().collect();
    let mut cuts = HashMap::new();
    let id_qb = count_cuts(&parsed, &mut cuts);
    assert_eq!(qa(&cuts), 4);
    assert_eq!(id_qb, 3);
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    let claims: Vec<&str> = buffer.lines().collect();
    let mut cuts = HashMap::new();
    let id_qb = count_cuts(&claims, &mut cuts);
    println!("qa: {}", qa(&cuts));
    println!("qb: {}", id_qb);
}
