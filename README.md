# Intentionally Vulnerable
## What this repo is
This repo demonstrates how an EIP-1167 clone factory works.

## Architecture at a glance
- **BaseCloneFactory**: Provides internal helper to deploy/predict determinisitic clones and then initialize for users.
- **VaultFactory**: Exposes the external entry points that allows the user to create and initialize the vault.
- **Implementation**: Template contract that used to provide initialize/deposit/withdraw logic for delegatecall-based clone instances.

## How to run
- **CloneFactory_Fuzz**: forge test --match-contract CloneFactory_Fuzz --fuzz-runs 5000 -vv
- **CloneFactory_Happy**: forge test --match-contract CloneFactory_Happy -vv
- **CloneFactory_Invariant**: forge test --match-contract CloneFactory_Invariant -vv
- **CloneFactory_PoC**: forge test --match-contract CloneFactory_PoC -vvvv
- **CloneFactory_Revert**: forge test --match-contract CloneFactory_Revert -vv

## Vulnerable vs Fixed
- **Current branch**: vulnerable demo
- **Fixed version**: (coming) branch fix / tag v0.1.1-fix
- **Reproduce vuln**: checkout v0.1.0-vuln then run PoC test above

## PoC & Finding
- **PoC test**: test/CloneFactory_PoC.t.sol
- **Finding report**: findings/CloneFactory_PoC_EN.md

## Known issues
- Missing initialization guards in Template.

## Out of scope
- Access control
- Multiple implementations
- Initialization calldata validation / typed init
- Event & indexing strategy
- ERC20 support(SafeERC20) / fee-on-transfer / non-standard ERC20
- Cross-protocol integration surfaces (permit / routers / callbacks)