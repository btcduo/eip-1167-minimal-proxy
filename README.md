# Fixed Version (EIP-1167 Clone Factory Demo)
## What this repo is
This repo demonstrates a minimal EIP-1167 clone factory workflow (predict -> deploy via CREATE2 -> initialize).

## Architecture at a glance
- **BaseCloneFactory**: Provides internal helper to deploy/predict determinisitic clones and then initialize for users.
- **VaultFactory**: Exposes the external entry points that allows the user to create and initialize the vault.
- **Implementation**: Template contract that used to provide initialize/deposit/withdraw logic for delegatecall-based clone instances.

## How to run
- **CloneFactory_Fuzz**: forge test --match-contract CloneFactory_Fuzz --fuzz-runs 5000 -vv
- **CloneFactory_Happy**: forge test --match-contract CloneFactory_Happy -vv
- **CloneFactory_Invariant**: forge test --match-contract CloneFactory_Invariant -vv
- **CloneFactory_PoC_Fixed**: forge test --match-contract CloneFactory_PoC_Fixed -vvvv
- **CloneFactory_Revert**: forge test --match-contract CloneFactory_Revert -vv

## Vulnerable vs Fixed
- **Current branch**: fixed version(recommended)
- **Vulnerable version**: tag v0.1.0-vuln
- **Fixed version**: tag v0.1.1-fix
- **Reproduce vulnerability**: checkout v0.1.0-vuln then run PoC test above

## PoC & Finding
- **PoC test**: test/CloneFactory_PoC.t.sol in tag: v0.1.0-vuln
- **Finding report**: findings/CloneFactory_PoC_EN.md

## Fix summary
- Hardended the implementation by disabling initializers in its constructor.

## Security notes
- Demo only. Not production-ready.

## Production considerations
- Access control
- Multiple implementations
- Initialization calldata validation / typed init
- Event & indexing strategy
- Asset support(SafeERC20 / fee-on-transfer / non-standard ERC20)
- Cross-protocol integration surfaces (permit / routers / callbacks / etc.)