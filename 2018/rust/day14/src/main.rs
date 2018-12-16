use std::io::{stdin, Read};
use std::str::FromStr;

fn break_digits(num: u8) -> Vec<u8> {
    assert!(num < 19);

    let mut res = Vec::new();
    if num >= 10 {
        res.push(num / 10);
    }
    res.push(num % 10);
    res
}

fn to_digits(input: &str) -> Vec<u8> {
    let mut res = Vec::new();
    for c in input.chars() {
        let string_c = c.to_string();
        res.push(u8::from_str(&string_c).expect("failed to cast string_c to u8"));
    }

    res
}

fn qaqb(input: &str) -> (String, String) {
    let nrecipes = usize::from_str(input).expect("failed to cast nrecipes to u32");
    let wanted_scores = to_digits(input);

    let mut recipe_scores = vec![3u8, 7];
    let mut elfa_at = 0;
    let mut elfb_at = 1;

    let mut resa = None;
    let mut resb = None;
    // Build up the recipe list
    while resa.is_none() || resb.is_none() {
        // Elves pick new recipes
        elfa_at = (elfa_at + recipe_scores[elfa_at] as usize + 1) % recipe_scores.len();
        elfb_at = (elfb_at + recipe_scores[elfb_at] as usize + 1) % recipe_scores.len();

        // Make new recipes
        let recipes_sum = recipe_scores[elfa_at] + recipe_scores[elfb_at];
        let new_recipes = break_digits(recipes_sum);
        recipe_scores.extend(new_recipes);

        // Check result for part one
        if recipe_scores.len() >= nrecipes + 10 {
            let mut stra = String::new();
            // Compute the scores of "the ten recipes after that"
            for score in &recipe_scores[nrecipes..nrecipes + 10] {
                let str_score = format!("{}", score);
                stra.push_str(&str_score);
            }
            resa = Some(stra);
        }

        // Check result for part two
        let len_scores = recipe_scores.len();
        let len_wanted = wanted_scores.len();
        if resb.is_none() {
            if len_scores >= len_wanted
                && &recipe_scores[len_scores - len_wanted..] == wanted_scores.as_slice()
            {
                let strb = format!("{}", len_scores - len_wanted);
                resb = Some(strb);
            }  else if  len_scores > len_wanted
                && &recipe_scores[len_scores - len_wanted - 1..len_scores - 1]
                == wanted_scores.as_slice()
            {
                let strb = format!("{}", len_scores - len_wanted - 1);
                resb = Some(strb);
            }
        }
    }

    (
        resa.expect("no result for qa"),
        resb.expect("no result for qb"),
    )
}

fn main() {
    let mut buffer = String::new();
    stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");
    buffer = buffer.trim().to_string();
    //let tmp = String::from("610103");
    let (qa, qb) = qaqb(&buffer);
    println!("qa: {}", qa);
    println!("qb: {}", qb);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_break_digits() {
        assert_eq!(break_digits(12), vec!(1, 2));
        assert_eq!(break_digits(5), vec!(5));
    }

    #[test]
    fn test_to_digits() {
        assert_eq!(to_digits("01234"), vec!(0, 1, 2, 3, 4));
    }

    #[test]
    fn test_qa() {
        assert_eq!(qaqb("9").0, String::from("5158916779"));
        assert_eq!(qaqb("5").0, String::from("0124515891"));
        assert_eq!(qaqb("18").0, String::from("9251071085"));
        assert_eq!(qaqb("2018").0, String::from("5941429882"));
    }

    #[test]
    fn test_qb() {
        assert_eq!(qaqb("51589").1, String::from("9"));
        assert_eq!(qaqb("01245").1, String::from("5"));
        assert_eq!(qaqb("92510").1, String::from("18"));
        assert_eq!(qaqb("59414").1, String::from("2018"));
    }
}
