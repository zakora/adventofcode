use std::io::{self, Read};
use std::str::FromStr;

// struct Node<'a> {
//     child_qty: u32,
//     metadata_qty: u32,
//     child_nodes: Vec<&'a Node<'a>>,
//     metadata: Vec<u32>,
// }

fn qa(numbers: &mut Vec<usize>) -> usize {
    let mut idx: i32 = 0;
    let mut metadatas = Vec::new();

    while numbers.len() > 0 {
        // Walk the list of numbers until a node with 0 child is found
        if numbers[idx as usize] == 0 {
            let nmetadata = numbers[idx as usize + 1];
            metadatas.extend(&numbers[idx as usize + 2 .. idx as usize + 2 + nmetadata]);

            for _ in 0 .. 2 + nmetadata as i32 {
                numbers.remove(idx as usize);
            }

            // Decrement the child count on our parent,
            // but make sure there are still some nodes!
            if numbers.len() > 0 {
                idx -= 2;
                numbers[idx as usize] -= 1;
            }
        } else {
            idx += 2;
        }
    }

    metadatas.iter().sum::<usize>()
}

#[test]
fn test_qa() {
    let mut numbers = vec!(2usize, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2);
    assert_eq!(qa(&mut numbers), 138);

    let mut numbers2 = vec!(2usize, 3, 1, 1, 0, 1, 99, 2, 0, 3, 10, 11, 12, 1, 1, 2);
    assert_eq!(qa(&mut numbers2), 138);
}

fn main() {
    // Parse input into a list of numbers
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    let mut numbers: Vec<usize> = buffer
        .split_whitespace()
        .map(|num| usize::from_str(num).expect("failed to cast number"))
        .collect();

    println!("qa: {}", qa(&mut numbers));
}
