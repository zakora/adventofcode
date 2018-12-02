use std::collections::HashMap;
use std::io::{self, Read};

/// For each letter, compute how many times it appears in the box ID
fn count_letters(boxid: &str, counts: &mut HashMap<char, i32>) {
    for letter in boxid.chars() {
        let count = counts.entry(letter).or_insert(0);
        *count += 1;
    }
}

/// Compute two counts:
/// 1. number of letter pairs in the box ID
/// 2. number of letter triples in the box ID
fn count_pairs_triples(boxid: &str) -> (i32, i32) {
    let mut counts = HashMap::new();
    count_letters(boxid, &mut counts);
    // Filter and sum letters that appears exactly 2 and 3 times in the box ID.
    let mut res = (0, 0);
    for (_letter, count) in counts {
        if count == 2 {
            res.0 += 1;
        } else if count == 3 {
            res.1 += 1;
        }
    }
    res
}

#[test]
fn test_count_pairs_triples() {
    assert_eq!(count_pairs_triples("abcdef"), (0, 0));
    assert_eq!(count_pairs_triples("bababc"), (1, 1));
    assert_eq!(count_pairs_triples("abbcde"), (1, 0));
    assert_eq!(count_pairs_triples("abcccd"), (0, 1));
    assert_eq!(count_pairs_triples("aabcdd"), (2, 0));
    assert_eq!(count_pairs_triples("abcdee"), (1, 0));
    assert_eq!(count_pairs_triples("ababab"), (0, 2));
}

/// Check if a box ID has a letter pair or a letter triple
fn has_pair_triple(boxid: &str) -> (i32, i32) {
    let (pairs, triples) = count_pairs_triples(boxid);
    (
        if pairs > 0 { 1 } else { 0 },
        if triples > 0 { 1 } else { 0 },
    )
}

#[test]
fn test_has_pair_triple() {
    assert_eq!(has_pair_triple("abcdef"), (0, 0));
    assert_eq!(has_pair_triple("bababc"), (1, 1));
    assert_eq!(has_pair_triple("abbcde"), (1, 0));
    assert_eq!(has_pair_triple("abcccd"), (0, 1));
    assert_eq!(has_pair_triple("aabcdd"), (1, 0));
    assert_eq!(has_pair_triple("abcdee"), (1, 0));
    assert_eq!(has_pair_triple("ababab"), (0, 1));
}

/// Check for letter pairs and triples in each box ID,
/// then compute [box IDs with pairs] * [box IDs with triples].
fn qa(input: &str) -> i32 {
    let [npairs, ntriples] = input
        .lines()
        .map(|boxid| has_pair_triple(boxid))
        .fold([0, 0], |[pairs, triples], (has_pair, has_triple)| {
            [pairs + has_pair, triples + has_triple]
        });

    npairs * ntriples
}

#[test]
fn test_qa() {
    let input = r#"abcdef
                   bababc
                   abbcde
                   abcccd
                   aabcdd
                   abcdee
                   ababab"#;
    assert_eq!(qa(input), 12);
}

fn differ_one_char(a: &str, b: &str) -> bool {
    let mut diff = 0;
    
    for (cha, chb) in a.chars().zip(b.chars()) {
        if cha != chb {
            diff += 1;
        }
    }
    
    diff == 1
}

#[test]
fn test_differ_one_char() {
    assert!(!differ_one_char("abcde", "axcye"));
    assert!(differ_one_char("fghij", "fguij"));
}

fn extract_diff(a: &str, b: &str) -> String {
    let mut res = String::new();
    for (cha, chb) in a.chars().zip(b.chars()) {
        if cha == chb {
            res.push(cha.clone());
        }
    }
    res
}

#[test]
fn test_extract_diff() {
    assert_eq!(extract_diff("fghij", "fguij"), "fgij");
    assert_eq!(extract_diff("abcdef", "abcdeZ"), "abcde");
    assert_eq!(extract_diff("Zabc", "Yabc"), "abc");
}

fn qb(input: &str) -> String {
    let boxids: Vec<&str> = input.split_whitespace().collect();

    for (idx, boxid) in boxids.iter().enumerate() {
        for cmp_idx in (idx + 1)..boxids.len() {
            let cmp_boxid = boxids[cmp_idx];
            if differ_one_char(boxid, cmp_boxid) {
                return extract_diff(boxid, cmp_boxid);
            }
        }
    }

    panic!("No solution");
}

#[test]
fn test_qb() {
    let input = r#"abcde
                   fghij
                   klmno
                   pqrst
                   fguij
                   axcye
                   wvxyz"#;
    assert_eq!(qb(input), "fgij");
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Failed to read from stdin");

    println!("qa: {}", qa(&buffer));
    println!("qb: {}", qb(&buffer));
}
