extern crate regex;

use regex::Regex;
use std::io::{self, Read};
use std::str::FromStr;

fn is_triangle(a: u32, b: u32, c: u32) -> bool {
    (a + b > c) && (a + c > b) && (b + c > a)
}

fn main() {
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from file");

    // QA
    let mut counta = 0;
    let re = Regex::new(r" *(\d+) *(\d+) *(\d+)").expect("failed to compile regex");

    for triangle in buffer.lines() {
        let caps = re.captures(triangle).expect("failed to capture regex");
        let (a, b, c) = (
            u32::from_str(&caps[1]).expect("failed to cast a"),
            u32::from_str(&caps[2]).expect("failed to cast b"),
            u32::from_str(&caps[3]).expect("failed to cast c"),
        );
        if is_triangle(a, b, c) {
            counta += 1;
        }
    }

    println!("qa: {}", counta);

    // QB
    let mut countb = 0;
    let reb = Regex::new(r"(?mx)
        # first line
        \s*(?P<a>\d+)\s*(?P<d>\d+)\s*(?P<g>\d+)\n

        # second line
        \s*(?P<b>\d+)\s*(?P<e>\d+)\s*(?P<h>\d+)\n

        # third line
        \s*(?P<c>\d+)\s*(?P<f>\d+)\s*(?P<i>\d+)\n")
        .expect("failed to compile regex");
    for capb in reb.captures_iter(&buffer) {
        let (a, b, c, d, e, f, g, h, i) = (
            u32::from_str(&capb["a"]).expect("failed to cast a"),
            u32::from_str(&capb["b"]).expect("failed to cast b"),
            u32::from_str(&capb["c"]).expect("failed to cast c"),
            
            u32::from_str(&capb["d"]).expect("failed to cast d"),
            u32::from_str(&capb["e"]).expect("failed to cast e"),
            u32::from_str(&capb["f"]).expect("failed to cast f"),

            u32::from_str(&capb["g"]).expect("failed to cast g"),
            u32::from_str(&capb["h"]).expect("failed to cast h"),
            u32::from_str(&capb["i"]).expect("failed to cast i"),
        );
        if is_triangle(a, b, c) {
            countb += 1
        }
        if is_triangle(d, e, f) {
            countb += 1
        }
        if is_triangle(g, h, i) {
            countb += 1
        }
    }
    println!("qb: {}", countb);
}
