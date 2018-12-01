use std::collections::HashSet;
use std::io::{self, Read};
use std::str::FromStr;

fn parse_freq_change(change: &str) -> i32 {
    let sign = match &change[0..1] {
        "+" => 1,
        "-" => -1,
        _ => panic!("Error: sign should be either '+' or '-'"),
    };
    
    let number = i32::from_str(&change[1..])
        .expect("failed to parse number");

    sign * number
}

#[test]
fn test_parse_freq_change() {
    assert_eq!(parse_freq_change("+12"), 12);
    assert_eq!(parse_freq_change("-1"), -1);
    assert_eq!(parse_freq_change("+0"), 0);
    assert_eq!(parse_freq_change("-0"), 0);
}


fn qb(buffer: &str) -> i32 {
    // Put numbers into a vector since we could iter over it multiple times.
    let changes: Vec<i32> = buffer.lines()
        .map(|num| parse_freq_change(num))
        .collect();

    // Walk the frequencies and keep a state for the current frequency 'res'
    let mut res = 0;
    let mut freq: i32;
    let mut index = 0;
    let length = changes.len();
    let mut known_freqs = HashSet::new();  // keep track of the walked by freqs
    loop {
        // Add the current frequency to a set
        known_freqs.insert(res);

        // Compute the next frequency and check if already seen
        freq = changes[index];
        res += freq;
        if known_freqs.contains(&res) {
            break res
        }

        // Increment the index and possibly go back to 0 if end of vector
        index = (index + 1) % length;
    }
}

#[test]
fn test_qb() {
    assert_eq!(qb("+1\n-1\n"), 0);
    assert_eq!(qb("+3\n+3\n+4\n-2\n-4"), 10);
    assert_eq!(qb("-6\n+3\n+8\n+5\n-6"), 5);
    assert_eq!(qb("+7\n+7\n-2\n-7\n-4"), 14);
}

fn main() {
    // Get the input from stdin
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    buffer
        .pop()
        .expect("failed to pop \\n");

    // Part one
    let resa: i32 = buffer.lines()
        .map(|ll| parse_freq_change(ll))
        .sum();
    println!("qa: {}", resa);

    // Part two
    println!("qb: {}", qb(&buffer));
}
