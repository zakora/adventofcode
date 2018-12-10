extern crate regex;

use regex::Regex;
use std::collections::HashSet;
use std::io::{stdin, Read};
use std::str::FromStr;

fn parse_input(input: &str) -> (Vec<(i64, i64)>, Vec<(i64, i64)>) {
    let mut positions = Vec::new();
    let mut velocities = Vec::new();
    let re = Regex::new(r"position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>")
        .expect("failed to create regex");

    for line in input.lines() {
        let caps = re.captures(line).expect("failed regex capture");
        let x = i64::from_str(&caps[1]).expect("failed to cast x to i64");
        let y = i64::from_str(&caps[2]).expect("failed to cast y to i64");
        let dx = i64::from_str(&caps[3]).expect("failed to cast dx to i64");
        let dy = i64::from_str(&caps[4]).expect("failed to cast dy to i64");

        positions.push((x, y));
        velocities.push((dx, dy));
    }

    (positions, velocities)
}

fn bounding_box(positions: &Vec<(i64, i64)>) -> ((i64, i64), (i64, i64)) {
    let (xmin, _y) = positions.iter().min_by_key(|(x, _y)| x).expect("no xmin");
    let (_x, ymin) = positions.iter().min_by_key(|(_x, y)| y).expect("no ymin");
    let (xmax, _y) = positions.iter().max_by_key(|(x, _y)| x).expect("no xmax");
    let (_x, ymax) = positions.iter().max_by_key(|(_x, y)| y).expect("no ymax");

    // Return top-left & bot-right points
    ((*xmin, *ymax), (*xmax, *ymin))
}

fn format_positions(positions: &Vec<(i64, i64)>) -> String {
    let mut res = String::new();
    let margin = 3;
    let set_positions: HashSet<&(i64, i64)> = positions.into_iter().collect();
    let ((xmin, ymax), (xmax, ymin)) = bounding_box(&positions);

    for yy in (ymin - margin)..(ymax + margin) {
        for xx in (xmin - margin)..(xmax + margin) {
            if set_positions.contains(&(xx, yy)) {
                res.push('#');
            } else {
                res.push('.');
            }
        }
        res.push('\n');
    }
    res
}

fn size(positions: &Vec<(i64, i64)>) -> i64 {
    let ((xmin, ymax), (xmax, ymin)) = bounding_box(&positions);
    ((xmin - xmax).abs() * (ymin - ymax).abs())
}

fn step(positions: &mut Vec<(i64, i64)>, velocities: &Vec<(i64, i64)>) {
    for ii in 0..positions.len() {
        let (x, y) = positions[ii];
        let (dx, dy) = velocities[ii];
        let (nx, ny) = (x + dx, y + dy);
        positions[ii] = (nx, ny);
    }
}

fn qa(mut positions: &mut Vec<(i64, i64)>, velocities: &Vec<(i64, i64)>) -> u32 {
    let mut seconds = 0;
    loop {
        let size_before = size(&positions);
        let tmp_positions = positions.clone();
        step(&mut positions, &velocities);
        let size_after = size(&positions);
        if size_after > size_before {
            println!("qa:");
            println!("{}", format_positions(&tmp_positions));
            break;
        }
        seconds += 1;
    }
    seconds
}

fn main() {
    let mut buffer = String::new();
    stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    let (mut positions, velocities) = parse_input(&buffer);

    let seconds = qa(&mut positions, &velocities);
    println!("qb: {}", seconds);
}
