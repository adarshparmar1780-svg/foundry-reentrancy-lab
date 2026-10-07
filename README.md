A small local learning example comparing a withdraw function that updates its balance after an external call with one that follows checks-effects-interactions.

`VulnerableVault` and `ReentrancyProbe` are intentionally unsafe. Use only on a local development chain with no valuable funds. `ChecksEffectsVault` illustrates updating accounting before the call; it is not audited or a production-ready vault.

## Run

Install [Foundry](https://book.getfoundry.sh/getting-started/installation), then from this directory run:

```sh
forge build
```

The source shows the vulnerable callback path: the probe's `receive` function calls `withdraw` again while the original balance is still recorded. In `ChecksEffectsVault`, the balance is cleared before control passes to the receiver, so another withdrawal has no available balance.

This is a narrow code-reading lab, not an audit or a complete reentrancy defense. Reentrancy can involve other state and other contracts; the Solidity documentation discusses the broader risk and checks-effects-interactions pattern: https://docs.soliditylang.org/en/latest/security-considerations.html#reentrancy

AI-assisted initial draft. Review, run locally, and make changes you understand before presenting it as your work.

## What I learned

The vulnerable vault sends ETH before clearing the caller’s recorded balance. A receiving contract can call `withdraw()` again during that transfer, while the old balance is still recorded. The checks-effects-interactions version clears the balance first, so this callback cannot withdraw that same balance again.