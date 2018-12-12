use std::collections::{HashMap, HashSet};
use std::io::{stdin, Read};

fn parse_init_state(state: &str) -> HashSet<i32> {
    let mut res = HashSet::new();
    for (idx, has_plant) in state.chars().enumerate() {
        if has_plant == '#' {
            res.insert(idx as i32);
        }
    }

    res
}

#[test]
fn test_parse_init_state() {
    let expected: HashSet<i32> = vec![0, 5, 6, 7, 8].into_iter().collect();
    assert_eq!(parse_init_state("#....####.."), expected);
}

fn parse_pattern(pattern: &str) -> Vec<bool> {
    let mut res = Vec::new();
    for pot in pattern.chars() {
        if pot == '#' {
            res.push(true);
        } else {
            res.push(false);
        }
    }

    res
}

#[test]
fn test_parse_pattern() {
    let expected = vec![true, false, false];
    assert_eq!(parse_pattern("#.."), expected);
}

fn parse_rule(rule: &str) -> (Vec<bool>, bool) {
    let splits: Vec<&str> = rule.split(" => ").collect();
    let str_rule = splits[0];
    let str_plant = splits[1];

    let pattern = parse_pattern(str_rule);

    let has_plant = if str_plant == "#" { true } else { false };

    (pattern, has_plant)
}

#[test]
fn test_parse_rule() {
    {
        let pattern = vec![true, false, true, false, true];
        assert_eq!(parse_rule("#.#.# => #"), (pattern, true));
    }
    {
        let pattern = vec![false, false, false, false, true];
        assert_eq!(parse_rule("....# => ."), (pattern, false));
    }
}

/// Given a pot position P, produces a list of (central pot position, pattern) close to P.
/// A pattern is close to P if it contains P.
fn get_nearby_pots(position: i32, state: &HashSet<i32>) -> Vec<(i32, Vec<bool>)> {
    let mut res = Vec::new();

    // Build the zone around the given position
    let mut nearby_pots = Vec::new();
    for dx in -4..5 {
        if state.contains(&(position + dx)) {
            nearby_pots.push(true);
        } else {
            nearby_pots.push(false);
        }
    }

    // Iter over all patterns in the zone
    for ii in 0..5 {
        let pattern = nearby_pots[ii..ii + 5].to_owned();
        res.push(((ii as i32) - 2 + position, pattern));
    }

    res
}

#[test]
fn test_get_nearby_pots() {
    let state: HashSet<i32> = vec![10].into_iter().collect();
    let p1 = vec![false, false, false, false, true];
    let p2 = vec![false, false, false, true, false];
    let p3 = vec![false, false, true, false, false];
    let p4 = vec![false, true, false, false, false];
    let p5 = vec![true, false, false, false, false];
    let expected = vec![(8, p1), (9, p2), (10, p3), (11, p4), (12, p5)];
    assert_eq!(get_nearby_pots(10, &state), expected);
}

fn evolve(state: &HashSet<i32>, rules: &HashMap<Vec<bool>, bool>, niter: u64) -> i32 {
    let mut current_gen: HashSet<i32> = state.clone();

    // Evolution
    for _ in 0..niter {
        // Match plant patterns to build the next generation
        let mut next_gen = HashSet::new();
        for pos_plant in &current_gen {
            for (idx, pattern) in get_nearby_pots(*pos_plant, &current_gen) {
                match rules.get(&pattern) {
                    Some(has_plant) => {
                        if *has_plant {
                            next_gen.insert(idx);
                        }
                    }
                    None => (),
                }
            }
        }
        current_gen = next_gen.clone();
    }

    // Sum pot numbers with plant
    current_gen.iter().sum::<i32>()
}

fn qb(init_state: &HashSet<i32>, rules: &HashMap<Vec<bool>, bool>) -> i64{
    // Get two values far enough so the system is linear
    let x1 = 1000i64;
    let y1 = evolve(&init_state, &rules, x1 as u64) as i64;
    let x2 = 2000i64;
    let y2 = evolve(&init_state, &rules, x2 as u64) as i64;

    // Compute the linear function
    let a = (y2 - y1)/(x2 - x1);
    let b = y1 - a * x1;

    a * 50_000_000_000 + b
}

fn main() {
    let mut buffer = String::new();
    stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");

    // Parse initial state
    let mut lines = buffer.lines();
    let line_init = lines.next().expect("no line for initial state");
    let splits: Vec<&str> = line_init.split("initial state: ").collect();
    let init_state = parse_init_state(&splits[1]);

    // Parse rules
    let mut rules = HashMap::new();
    let line_rules = lines.skip(1);
    for r in line_rules {
        let (rule, has_plant) = parse_rule(r);
        rules.insert(rule, has_plant);
    }

    println!("qa: {}", evolve(&init_state, &rules, 20));
    println!("qb: {}", qb(&init_state, &rules));
}
