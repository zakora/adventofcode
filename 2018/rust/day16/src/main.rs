extern crate regex;

use regex::Regex;
use std::collections::{HashMap, HashSet};
use std::io::{stdin, Read};
use std::str::FromStr;

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
enum Instr {
    Addr,
    Addi,
    Mulr,
    Muli,
    Banr,
    Bani,
    Borr,
    Bori,
    Setr,
    Seti,
    Gtir,
    Gtri,
    Gtrr,
    Eqir,
    Eqri,
    Eqrr,
}

fn parse_samples(
    input: &str,
) -> Vec<(
    [u32; 4],             // registers before
    (u32, u32, u32, u32), // instruction
    [u32; 4],             // registers after
)> {
    let mut samples = Vec::new();

    let re_sample = Regex::new(
        r"(?m)^Before: \[(?P<reg0_before>\d+), (?P<reg1_before>\d+), (?P<reg2_before>\d+), (?P<reg3_before>\d+)\]$
^(?P<instr_opcode>\d+) (?P<instr_a>\d+) (?P<instr_b>\d+) (?P<instr_c>\d+)$
^After:  \[(?P<reg0_after>\d+), (?P<reg1_after>\d+), (?P<reg2_after>\d+), (?P<reg3_after>\d+)\]$",
    ).expect("failed to create regex");
    for cap_sample in re_sample.captures_iter(&input) {
        let (
            reg0_before,
            reg1_before,
            reg2_before,
            reg3_before,
            instr_opcode,
            instr_a,
            instr_b,
            instr_c,
            reg0_after,
            reg1_after,
            reg2_after,
            reg3_after,
        ) = (
            // Registers before
            u32::from_str(&cap_sample["reg0_before"]).expect("failed to cast reg0_before"),
            u32::from_str(&cap_sample["reg1_before"]).expect("failed to cast reg1_before"),
            u32::from_str(&cap_sample["reg2_before"]).expect("failed to cast reg2_before"),
            u32::from_str(&cap_sample["reg3_before"]).expect("failed to cast reg3_before"),
            // Instruction
            u32::from_str(&cap_sample["instr_opcode"]).expect("failed to cast instr_opcode"),
            u32::from_str(&cap_sample["instr_a"]).expect("failed to cast instr_a"),
            u32::from_str(&cap_sample["instr_b"]).expect("failed to cast instr_b"),
            u32::from_str(&cap_sample["instr_c"]).expect("failed to cast instr_c"),
            // Registers after
            u32::from_str(&cap_sample["reg0_after"]).expect("failed to cast reg0_after"),
            u32::from_str(&cap_sample["reg1_after"]).expect("failed to cast reg1_after"),
            u32::from_str(&cap_sample["reg2_after"]).expect("failed to cast reg2_after"),
            u32::from_str(&cap_sample["reg3_after"]).expect("failed to cast reg3_after"),
        );
        samples.push((
            [reg0_before, reg1_before, reg2_before, reg3_before],
            (instr_opcode, instr_a, instr_b, instr_c),
            [reg0_after, reg1_after, reg2_after, reg3_after],
        ));
    }

    samples
}

fn parse_instructions(input: &str) -> Vec<(u32, u32, u32, u32)> {
    let mut res = Vec::new();
    let re = Regex::new(r"(\d+) (\d+) (\d+) (\d+)").expect("failed to create regex");
    for cap in re.captures_iter(&input) {
        let instr = (
            u32::from_str(&cap[1]).expect("failed to cast reg0"),
            u32::from_str(&cap[2]).expect("failed to cast reg1"),
            u32::from_str(&cap[3]).expect("failed to cast reg2"),
            u32::from_str(&cap[4]).expect("failed to cast reg3"),
        );
        res.push(instr);
    }
    res
}

fn addr(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] + reg[b as usize];
    res
}

fn addi(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] + b;
    res
}

fn mulr(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] * reg[b as usize];
    res
}

fn muli(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] * b;
    res
}

fn banr(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] & reg[b as usize];
    res
}

fn bani(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] & b;
    res
}

fn borr(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] | reg[b as usize];
    res
}

fn bori(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize] | b;
    res
}

fn setr(reg: [u32; 4], a: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = reg[a as usize];
    res
}

fn seti(reg: [u32; 4], a: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = a;
    res
}

fn gtir(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = if a > reg[b as usize] { 1 } else { 0 };
    res
}

fn gtri(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = if reg[a as usize] > b { 1 } else { 0 };
    res
}

fn gtrr(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = if reg[a as usize] > reg[b as usize] {
        1
    } else {
        0
    };
    res
}

fn eqir(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = if a == reg[b as usize] { 1 } else { 0 };
    res
}

fn eqri(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = if reg[a as usize] == b { 1 } else { 0 };
    res
}

fn eqrr(reg: [u32; 4], a: u32, b: u32, c: u32) -> [u32; 4] {
    let mut res = reg;
    res[c as usize] = if reg[a as usize] == reg[b as usize] {
        1
    } else {
        0
    };
    res
}

fn hashset_instr(
    reg_before: [u32; 4],
    instr: (u32, u32, u32, u32),
    reg_after: [u32; 4],
) -> HashSet<Instr> {
    let mut res = HashSet::new();
    let (_op_code, a, b, c) = instr;

    if addr(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Addr);
    }
    if addi(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Addi);
    }

    if mulr(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Mulr);
    }
    if muli(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Muli);
    }

    if banr(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Banr);
    }
    if bani(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Bani);
    }

    if borr(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Borr);
    }
    if bori(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Bori);
    }

    if setr(reg_before, a, c) == reg_after {
        res.insert(Instr::Setr);
    }
    if seti(reg_before, a, c) == reg_after {
        res.insert(Instr::Seti);
    }

    if gtir(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Gtir);
    }
    if gtri(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Gtri);
    }
    if gtrr(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Gtrr);
    }

    if eqir(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Eqir);
    }
    if eqri(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Eqri);
    }
    if eqrr(reg_before, a, b, c) == reg_after {
        res.insert(Instr::Eqrr);
    }

    res
}

fn qa(input: &str) -> u32 {
    let mut res = 0;
    let samples = parse_samples(&input);

    for (reg_before, instr, reg_after) in samples {
        let instrs = hashset_instr(reg_before, instr, reg_after);
        if instrs.len() > 2 {
            res += 1;
        }
    }
    res
}

fn get_known_instrs(opcode_set_instrs: &HashMap<u32, HashSet<Instr>>) -> HashMap<u32, Instr> {
    let mut res = HashMap::new();
    for (opcode, instr) in opcode_set_instrs {
        if instr.len() == 1 {
            let new_instr: Instr = instr.iter().next().expect("no instr").clone();
            res.insert(*opcode, new_instr);
        }
    }
    res
}

fn qb(section_samples: &str, section_test_program: &str) -> u32 {
    let samples = parse_samples(&section_samples);

    // Init opcode mapping
    let mut opcode_set_instrs = HashMap::new();
    for opcode in 0..=15 {
        let instrs: HashSet<Instr> = vec![
            Instr::Addr,
            Instr::Addi,
            Instr::Mulr,
            Instr::Muli,
            Instr::Banr,
            Instr::Bani,
            Instr::Borr,
            Instr::Bori,
            Instr::Setr,
            Instr::Seti,
            Instr::Gtir,
            Instr::Gtri,
            Instr::Gtrr,
            Instr::Eqir,
            Instr::Eqri,
            Instr::Eqrr,
        ]
        .into_iter()
        .collect();
        opcode_set_instrs.insert(opcode, instrs);
    }

    // Iter over samples to identify opcode instruction
    for (reg_before, instr, reg_after) in samples {
        let opcode = instr.0;
        let possible_instr_set = hashset_instr(reg_before, instr, reg_after);
        let current_instr_set = opcode_set_instrs.get(&opcode).expect("no set found");
        let new_instr_set: HashSet<Instr> = current_instr_set
            .intersection(&possible_instr_set)
            .cloned()
            .collect();
        opcode_set_instrs.insert(opcode, new_instr_set);
    }

    // Deduce opcodes given the one that are known (i.e. only one Instr for this opcode)
    loop {
        let known_instrs = get_known_instrs(&opcode_set_instrs);
        if known_instrs.len() != 16 {
            for (opcode, instr) in known_instrs.iter() {
                for (cmp_opcode, instr_set) in opcode_set_instrs.iter_mut() {
                    if opcode != cmp_opcode {
                        instr_set.remove(&instr);
                    }
                }
            }
        } else {  // we found all opcode matches
            break
        }
    }

    // Reduce opcode mapping to instr to opcode => Instr (instead of opcode => Set(Instr))
    let opcode_instr = get_known_instrs(&opcode_set_instrs);
    println!("mapping: {:#?}", opcode_instr);
    
    // Run the test program
    let mut reg = [0, 0, 0, 0];
    let instructions = parse_instructions(&section_test_program);
    for (opcode, a, b, c) in instructions {
        let instr = opcode_instr.get(&opcode).expect("no matching opcode");
        reg = match instr {
            Instr::Addr => addr(reg, a, b, c),
            Instr::Addi => addi(reg, a, b, c),
            Instr::Mulr => mulr(reg, a, b, c),
            Instr::Muli => muli(reg, a, b, c),
            Instr::Banr => banr(reg, a, b, c),
            Instr::Bani => bani(reg, a, b, c),
            Instr::Borr => borr(reg, a, b, c),
            Instr::Bori => bori(reg, a, b, c),
            Instr::Setr => setr(reg, a, c),
            Instr::Seti => seti(reg, a, c),
            Instr::Gtir => gtir(reg, a, b, c),
            Instr::Gtri => gtri(reg, a, b, c),
            Instr::Gtrr => gtrr(reg, a, b, c),
            Instr::Eqir => eqir(reg, a, b, c),
            Instr::Eqri => eqri(reg, a, b, c),
            Instr::Eqrr => eqrr(reg, a, b, c),
        };
    }

    reg[0]
}

fn main() {
    let mut buffer = String::new();
    stdin()
        .read_to_string(&mut buffer)
        .expect("failed to read from stdin");

    // Split input into samples and test program
    let mut sections = buffer.split("\n\n\n\n");
    let section_samples = sections.next().expect("failed to get samples section");
    let section_test_program = sections.next().expect("failed to get test program");

    println!("qa: {}", qa(&section_samples));
    println!("qb: {}", qb(&section_samples, &section_test_program));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_samples() {
        let input = "Before: [3, 2, 1, 1]
9 2 1 2
After:  [3, 2, 2, 1]";
        let expected = vec![([3, 2, 1, 1], (9, 2, 1, 2), [3, 2, 2, 1])];
        assert_eq!(parse_samples(&input), expected);
    }

    #[test]
    fn test_count_opcodes() {
        let input = "Before: [3, 2, 1, 1]
9 2 1 2
After:  [3, 2, 2, 1]";
        let samples = parse_samples(&input);
        let (reg_before, instr, reg_after) = samples[0];
        assert_eq!(count_opcodes(reg_before, instr, reg_after), 3);
    }
}
