extern crate chrono;
extern crate regex;

use chrono::prelude::*;
use regex::Regex;
use std::collections::HashMap;
use std::io::{self, Read};
use std::str::FromStr;

#[derive(Debug, PartialEq)]
enum GuardState {
    BeginsShift,
    FallsAsleep,
    WakesUp,
}

#[derive(Debug)]
struct Record {
    timestamp: DateTime<Utc>,
    guard_id: u32,
    guard_state: GuardState,
}


fn histogram(xs: &Vec<u32>) -> HashMap<u32, u32> {
    let mut res = HashMap::new();
    for &x in xs {
        let count = res.entry(x).or_insert(0);
        *count += 1;
    }
    res
}

#[test]
fn test_histogram() {
    let xs = vec![0, 1, 2, 3, 0, 0, 1];
    let mut res = HashMap::new();
    res.insert(0, 3);
    res.insert(1, 2);
    res.insert(2, 1);
    res.insert(3, 1);
    assert_eq!(histogram(&xs), res);
}

/// Parse the unordered input and return the records in chronological order.
fn get_records(buffer: &str) -> Vec<Record> {
    // Parse datetime for each line
    let re = Regex::new(r"\[(.*)\] (.*)").expect("failed to make regex");
    let time_fmt = "%Y-%m-%d %H:%M";
    let mut vec_time_note = Vec::new();
    for line in buffer.lines() {
        let caps = re.captures(line).expect("failed regex capture");
        let cap_time = caps.get(1).expect("failed to get time").as_str();
        let time = Utc
            .datetime_from_str(cap_time, time_fmt)
            .expect("failed to parse datetime");
        let note = caps.get(2).expect("failed to get note").as_str();
        vec_time_note.push((time, note));
    }
    // Sort by chronological order
    vec_time_note.sort_by(|(timea, _), (timeb, _)| timea.cmp(timeb));

    // Build records
    let mut records = Vec::new();
    let mut opt_guard_id = None;
    let re_guard = Regex::new(r"Guard #(\d+) begins shift").expect("failed to create regex");
    for (timestamp, note) in vec_time_note {
        let guard_state = match note {
            "wakes up" => GuardState::WakesUp,
            "falls asleep" => GuardState::FallsAsleep,
            _shift => GuardState::BeginsShift,
        };

        opt_guard_id = if guard_state == GuardState::BeginsShift {
            let caps_note = re_guard.captures(note).expect("failed regex capture");
            let cap_guard_id = caps_note.get(1).expect("failed to get guard id").as_str();
            Some(u32::from_str(cap_guard_id).expect("failed to cast guard id"))
        } else {
            opt_guard_id
        };
        let guard_id = match opt_guard_id {
            Some(id) => id,
            None => panic!("failed to get guard id"),
        };

        records.push(Record {
            timestamp,
            guard_id,
            guard_state,
        });
    }

    records
}


fn guard_sleeps(records: &Vec<Record>) -> HashMap<u32, Vec<u32>> {
    let mut res = HashMap::new();
    let mut sleep_start = None;
    for Record { timestamp, guard_id, guard_state } in records {
        let mut sleeping_minutes = res.entry(*guard_id)
            .or_insert(Vec::new());

        // If end of sleep time, add all minutes the guard was asleep.
        match (sleep_start, guard_state) {
            (Some(start_minute), GuardState::WakesUp) => {
                let stop_minute: u32 = timestamp.minute();
                for mm in start_minute .. stop_minute {
                    (*sleeping_minutes).push(mm);
                }
            },
            _ => (),
        }

        sleep_start = match guard_state {
            GuardState::FallsAsleep => Some(timestamp.minute()),
            GuardState::BeginsShift | GuardState::WakesUp => None,
        };
    }
    
    res
}

fn qa(guard_sleep_minutes: &HashMap<u32, Vec<u32>>) -> u32 {
    let mut totals: HashMap<u32, usize> = HashMap::new();
    for (guard_id, sleeping_minutes) in guard_sleep_minutes {
        totals.insert(*guard_id, sleeping_minutes.len());
    }

    let mut max_id = None;
    let mut max_minutes = 0;
    for (&id, &minutes) in &totals {
        if minutes > max_minutes {
            max_minutes = minutes;
            max_id = Some(id);
        }
    }

    let hist = histogram(&guard_sleep_minutes[&max_id.unwrap()]);
    let mut max_minute = 0;
    let mut max_count = 0;
    for (minute, count) in hist {
        if count > max_count {
            max_minute = minute;
            max_count = count;
        }
    }

    max_minute * max_id.unwrap()
}

/// Returns (key, val) where val is the highest value of the given hashmap.
fn hashmap_max(hashmap: HashMap<u32, u32>) -> (u32, u32) {
    let mut key_max = None;
    let mut val_max = None;

    for (key, val) in hashmap {
        match val_max {
            None => {
                key_max = Some(key);
                val_max = Some(val);
            },
            Some(current_max) => {
                if val > current_max {
                    key_max = Some(key);
                    val_max = Some(val);
                }
            },
        }
    }
    (key_max.expect("no key max found"), val_max.expect("no val max found"))
}

fn qb(guard_sleep_minutes: &HashMap<u32, Vec<u32>>) -> u32 {
    // Compute sleep minute histograms for each guard.
    let mut histograms = HashMap::new();
    for (guard_id, sleep_minutes) in guard_sleep_minutes {
        histograms.insert(guard_id, histogram(sleep_minutes));
    }

    // Compute the minute the most slept for each guard.
    let mut max_minutes = HashMap::new();
    for (guard_id, minutes) in histograms {
        // Some guard never sleeps, careful!
        if minutes.len() > 0 {
            let (max_minute, count) = hashmap_max(minutes);
            max_minutes.insert(guard_id, (max_minute, count));
        }
    }

    let mut res_guard_id = None;
    let mut res_minute = None;
    let mut max_count = None;
    for (guard_id, (minute, count)) in max_minutes {
        match max_count {
            None => {
                res_guard_id = Some(guard_id);
                res_minute = Some(minute);
                max_count = Some(count);
            },
            Some(cur_count) => {
                if count > cur_count {
                    res_guard_id = Some(guard_id);
                    res_minute = Some(minute);
                    max_count = Some(count);
                }
            },
        }
    }
    
    res_guard_id.expect("failed to get guard id") * res_minute.expect("failed to get minute")
}

#[test]
fn test_qa_qb() {
    let input = "[1518-11-01 00:00] Guard #10 begins shift
                 [1518-11-01 00:05] falls asleep
                 [1518-11-01 00:25] wakes up
                 [1518-11-01 00:30] falls asleep
                 [1518-11-01 00:55] wakes up
                 [1518-11-01 23:58] Guard #99 begins shift
                 [1518-11-02 00:40] falls asleep
                 [1518-11-02 00:50] wakes up
                 [1518-11-03 00:05] Guard #10 begins shift
                 [1518-11-03 00:24] falls asleep
                 [1518-11-03 00:29] wakes up
                 [1518-11-04 00:02] Guard #99 begins shift
                 [1518-11-04 00:36] falls asleep
                 [1518-11-04 00:46] wakes up
                 [1518-11-05 00:03] Guard #99 begins shift
                 [1518-11-05 00:45] falls asleep
                 [1518-11-05 00:55] wakes up";
    let records = get_records(input);
    let sleeps = guard_sleeps(&records);
    assert_eq!(qa(&sleeps), 240);
    assert_eq!(qb(&sleeps), 4455);
}

fn main() {
    // Get stdin
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");

    // Build records
    let records = get_records(&buffer);
    let guard_sleep_minutes = guard_sleeps(&records);

    println!("qa: {}", qa(&guard_sleep_minutes));
    println!("qb: {}", qb(&guard_sleep_minutes));
}
