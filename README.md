# Fixed Version (EIP-1167 Clone Factory Demo)
## What this repo is
This repo demonstrates a minimal EIP-1167 clone factory workflow (predict -> deploy via CREATE2 -> initialize).

## Architecture at a glance
- **BaseCloneFactory**: Provides internal helper to deploy/predict deterministic clones and then initialize for users.
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
- Hardened the implementation by disabling initializers in its constructor.

## Security notes
- Demo only. Not production-ready.

## Production considerations
- Access control
- Multiple implementations
- Initialization calldata validation / typed init
- Event & indexing strategy
- Asset support(SafeERC20 / fee-on-transfer / non-standard ERC20)
- Cross-protocol integration surfaces (permit / routers / callbacks / etc.)

## RPC config (Sepolia)
- This repo uses a named Foundry RPC endpoint: `sepolia` (defined in `foundry.toml`).
- Create `.env` from `.env.example` and fill `SEPOLIA_RPC_URL` + `PRIVATE_KEY`.
- Forge will auto-load `.env` from the project root (no need to `source`).

```bash
cp .env.example .env
# edit .env: set SEPOLIA_RPC_URL and PRIVATE_KEY
forge script script/DeploySepolia.s.sol:DeploySepolia --rpc-url sepolia --broadcast -vvvv
forge script script/InteractSepolia.s.sol:InteractSepolia --rpc-url sepolia --broadcast -vvvv
```

## Sepolia deployment (Foundry)
- **canonical demo deployment**
- Chain: Ethereum Sepolia (chainId: 11155111)
- Deployer: `0x0049ceacf337b8adcacf06a5bf3b1878228c87bb`
- Implementation: `0x3a8a4a4dFfc21C65E0aC8578993ec6CD80082dF8`
    - Deploy tx: `0x0721a685fd5fb0cdf3a18426c7d5b3702f894cadb2c09119f0290283e7c571b3`
    - Block: `9925122`
- Factory: `0xEDB841E9A5DCAe0D3b06E8f23f642f443740c00f`
    - Deploy tx: `0x6fa5a25377392d3cc78875e5a8f46b8e0959d32aaa00528fc59c4be85530944b`
    - Block: `9925122`

## Testnet interaction (Sepolia)
**Interaction tx hashes are recorded in:**
- `broadcast/InteractSepolia.s.sol/11155111/run-latest.json`
- `deployments/sepolia.v0.1.1-fix.json` -> `interactions[]`

## Verify
- Impl:    https://sepolia.etherscan.io/address/0x3a8a4a4dFfc21C65E0aC8578993ec6CD80082dF8#code
- Factory: https://sepolia.etherscan.io/address/0xEDB841E9A5DCAe0D3b06E8f23f642f443740c00f#code
- Requires .env with SEPOLIA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY (see .env.example).

Reproduce:
```bash
forge script script/DeploySepolia.s.sol:DeploySepolia \
    --rpc-url sepolia \
    --broadcast \
    --verify \
    -vvvv
```

## Sepolia deployment (Hardhat)
- **toolchain parity (deploy + verify) proof**
Implementation
- Address: 0xc2832ca87A507D1ee0fbE6021314537Cfad1c286
- Etherscan: https://sepolia.etherscan.io/address/0xc2832ca87A507D1ee0fbE6021314537Cfad1c286#code

VaultFactory
- Address: 0x3D5CE24CEc7c9064270885f69a83e91bB1aBd61a
- Etherscan: https://sepolia.etherscan.io/address/0x3D5CE24CEc7c9064270885f69a83e91bB1aBd61a#code