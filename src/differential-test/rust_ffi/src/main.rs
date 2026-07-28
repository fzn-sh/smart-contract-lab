use std::env;

fn fib(n: u32) -> u128 {
    if n == 0 {
        return 0;
    }
    let mut a: u128 = 0;
    let mut b: u128 = 1;
    for _ in 1..n {
        let c = a + b;
        a = b;
        b = c;
    }
    b
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: {} <n>", args[0]);
        std::process::exit(1);
    }

    let n: u32 = args[1].parse().expect("Invalid integer input");

    let result = fib(n);
    
    println!("0x{:0>64x}", result);
}