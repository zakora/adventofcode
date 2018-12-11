use std::collections::HashMap;
use std::io::{stdin, Read};
use std::str::FromStr;

fn power_level(x: u32, y: u32, gsn: i32) -> i32 {
    let rack_id = (x as i32) + 10;
    let mut power_level = rack_id * (y as i32);
    power_level += gsn;
    power_level *= rack_id;
    power_level = (power_level % 1000) / 100;
    power_level -= 5;

    power_level
}

#[test]
fn test_power_level() {
    assert_eq!(power_level(3, 5, 8), 4);
    assert_eq!(power_level(122, 79, 57), -5);
    assert_eq!(power_level(217, 196, 39), 0);
    assert_eq!(power_level(101, 153, 71), 4);
}

/// Initialize the grid with mappings (x, y) -> fuel cell power
fn init_grid(gsn: i32) -> HashMap<(u32, u32), i32> {
    let mut grid = HashMap::new();
    for xx in 1..301 {
        for yy in 1..301 {
            grid.insert((xx, yy), power_level(xx, yy, gsn));
        }
    }

    grid
}

#[allow(dead_code)]
fn print_grid(grid: &HashMap<(u32, u32), i32>) {
    let mut format_grid = String::new();
    for yy in 1..301 {
        for xx in 1..301 {
            let cell_power = grid.get(&(xx, yy)).expect("failed to get grid value");
            let fmt_cell_power = format!("{:>3}", cell_power);
            format_grid.push_str(&fmt_cell_power);
        }
        format_grid.push('\n');
    }
    print!("{}", format_grid);
}

/// Compute the total power for each NxN square on the grid
fn compute_squares(grid: &HashMap<(u32, u32), i32>, size: u32) -> HashMap<(u32, u32), i32> {
    let mut power_squares = HashMap::new();
    for xx in 1..(300 - size + 2) {
        for yy in 1..(300 - size + 2) {
            let mut power = 0;
            for dxx in 0..size {
                for dyy in 0..size {
                    power += grid
                        .get(&(xx + dxx, yy + dyy))
                        .expect("failed to get grid power");
                }
            }
            power_squares.insert((xx, yy), power);
        }
    }

    power_squares
}

// fn compute_squares_faster(grid: &HashMap<(u32, u32), i32>, size: u32) -> HashMap<(u32, u32), i32> {
//     let mut power_squares = HashMap::new();
//     for xx in 1..(300 - size + 2) {
//         for yy in 1..(300 - size + 2) {
//             let grid_power = grid.get(&(xx, yy)).expect("failed to get grid power");
//             for dxx in 0..size {
//                 for dyy in 0..size {
//                     let square_power = power_squares.entry((xx + dxx, yy + dyy))
//                         .or_insert(0);
//                     *square_power += grid_power;
//                 }
//             }
//         }
//     }

//     power_squares
// }

fn find_max(power_squares: &HashMap<(u32, u32), i32>) -> ((u32, u32), i32) {
    let (x, y) = *power_squares
        .keys()
        .max_by_key(|coord| {
            power_squares
                .get(*coord)
                .expect("failed to get grid power level")
        })
        .expect("no max found");
    let power_level = power_squares.get(&(x, y)).expect("failed to get max grid power level");

    ((x, y), *power_level)
}

fn qa(grid: &HashMap<(u32, u32), i32>) -> (u32, u32) {
    let power_squares = compute_squares(&grid, 3);
    let ((x, y), _power_level) = find_max(&power_squares);

    (x, y)
}
 
fn qb(grid: &HashMap<(u32, u32), i32>) -> (u32, u32, u32) {
    let mut max = None;

    for size in 1..301 {
        println!("current size: {}", size);
        let power_squares = compute_squares(&grid, size);
        let ((x, y), power_level) = find_max(&power_squares);

        max = match max {
            None => Some((x, y, size, power_level)),
            Some(val) => {
                let (_x, _y, _size, clevel) = val;
                if power_level > clevel {
                    Some((x, y, size, power_level))
                } else {
                    Some(val)
                }
            },
        };
    }

    let (x, y, size, _level) = max.expect("no max found");
    (x, y, size)
}


#[test]
fn test_qb() {
    assert_eq!(qb(&init_grid(18)), (90, 269, 16));
    assert_eq!(qb(&init_grid(42)), (232,251,12));
}

fn main() {
    let mut buffer = String::new();
    stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    buffer.pop().expect("failed to pop last \\n from buffer");
    let grid_serial_number = i32::from_str(&buffer).expect("failed to parse GSN");
    let grid = init_grid(grid_serial_number);

    let (qa_x, qa_y) = qa(&grid);
    println!("qa: {},{}", qa_x, qa_y);

    let (qb_x, qb_y, qb_size) = qb(&grid);
    println!("qb: {},{},{}", qb_x, qb_y, qb_size);
}
