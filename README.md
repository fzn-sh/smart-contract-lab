# Smart Contract Lab

A collection of Solidity exercises and experiments built with [Foundry](https://book.getfoundry.sh/).

## Project structure

```text
src/
├── basics/       # Solidity fundamentals
├── handbook/     # Implementation examples and integration tests
├── invariant/    # Invariant testing
├── fuzz/         # Fuzz testing
├── fork/         # Fork testing
└── *.sol         # General contract examples
test/             # General contract tests
script/           # Deployment scripts
lib/              # Foundry dependencies
```

## Quick start

```shell
forge build
forge test
forge fmt --check
```

To run a specific test:

```shell
forge test --match-path test/MinimalERC20.t.sol
```

## Local deployment

Start a local node with `anvil`, then deploy the example token:

```shell
forge script script/MinimalERC20.s.sol:MinimalERC20_Deploy \
  --rpc-url <your_rpc_url> \
  --private-key <your_private_key> \
  --broadcast
```

Other available tools include `cast`, `anvil`, and `chisel`.
