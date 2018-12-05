use std::collections::HashSet;
use std::io::{self, Read};

fn to_units(input: &str) -> Vec<char> {
    input.chars().collect()
}

#[test]
fn test_to_units() {
    assert_eq!(to_units("aA"), vec!['a', 'A']);
    assert_eq!(
        to_units("dabCBAcaDA"),
        vec!('d', 'a', 'b', 'C', 'B', 'A', 'c', 'a', 'D', 'A')
    );
}

fn can_react(a: char, b: char) -> bool {
    let cha = a
        .to_uppercase()
        .next()
        .expect("failed to convert to uppercase");
    let chb = b
        .to_uppercase()
        .next()
        .expect("failed to convert to uppercase");
    let same_type = cha == chb;
    let opposite_polarity = same_type && (a != b);

    same_type && opposite_polarity
}

#[test]
fn test_can_react() {
    assert_eq!(can_react('a', 'A'), true);
    assert_eq!(can_react('b', 'B'), true);
    assert_eq!(can_react('A', 'A'), false);
    assert_eq!(can_react('b', 'b'), false);
    assert_eq!(can_react('x', 'Y'), false);
}

fn react(units: &Vec<char>) -> Vec<char> {
    /* Walk the units.
     * Keep track of past units in a vector.
     * Pop last vector unit, compare it to current input unit.
     * IF same type + opposite polarity : continue
     * ELSE add the two units to the vector.
     */
    let mut res = Vec::new();
    for unit in units {
        let last = res.pop();
        match last {
            Some(last_unit) => {
                if !can_react(last_unit, *unit) {
                    res.push(last_unit);
                    res.push(*unit);
                }
            }
            None => {
                res.push(*unit);
            }
        }
    }

    res
}

fn qa(units: &Vec<char>) -> usize {
    react(&units).len()
}

#[test]
fn test_qa() {
    assert_eq!(qa(&to_units("aA")), 0);
    assert_eq!(qa(&to_units("abBA")), 0);
    assert_eq!(qa(&to_units("abAB")), 4);
    assert_eq!(qa(&to_units("aabAAB")), 6);
    assert_eq!(qa(&to_units("dabAcCaCBAcCcaDA")), 10);
}

fn alphabet(letters: &Vec<char>) -> HashSet<char> {
    letters
        .to_owned()
        .into_iter()
        .map(|ch| {
            ch.to_lowercase()
                .next()
                .expect("failed to convert to lowercase")
        }).collect()
}

#[test]
fn test_alphabet() {
    let v = vec!['a', 'b', 'c', 'b', 'B', 'A'];
    let mut set = HashSet::new();
    set.insert('a');
    set.insert('b');
    set.insert('c');
    assert_eq!(alphabet(&v), set);
}

/// Return a pair of polarity opposed units given a 'lowercase' unit.
fn unit_pair(lower: char) -> (char, char) {
    let upper = lower
        .to_uppercase()
        .next()
        .expect("failed to convert to uppercase");
    (lower, upper)
}

fn qb(units: &Vec<char>) -> usize {
    let mut mini = None;
    for unit_code in alphabet(&units) {
        let (lower, upper) = unit_pair(unit_code);
        // 1. remove lower & upper from units
        let filtered_polymer: Vec<char> = units
            .to_owned()
            .into_iter()
            .filter(|&unit| unit != lower && unit != upper)
            .collect();
        let reacted_polymer = react(&filtered_polymer);

        // 2. compute length of fully reacted polymer
        mini = match mini {
            Some(current_mini) => {
                if reacted_polymer.len() < current_mini {
                    Some(reacted_polymer.len())
                } else {
                    mini
                }
            },
            None => Some(reacted_polymer.len())
        }
    }

    mini.expect("no minimum")
}

#[test]
fn test_qb() {
    assert_eq!(qb(&to_units("dabAcCaCBAcCcaDA")), 4);
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    buffer.pop().expect("failed to pop final \\n");

    let units = to_units(&buffer);
    println!("qa: {}", qa(&units));
    println!("qb: {}", qb(&units));
}
