import { network } from "hardhat";
import fs from "node:fs";
import path from "node:path";

type DeploymentJson = {
    network: string;
    chainId: string;
    deployedAt: string;
    deployer: string;
    contracts: Record<
        string,
        {
            address: string;
            txHash: string | null;
            constructorArgs?: unknown[];
        }
    >;
};

async function main() {
    const conn = (await network.connect()) as any;
    const ethers = conn.ethers;
    const networkName = conn.networkName ?? "sepolia";
    const [deployer] = await ethers.getSigners();

    const deployerAddr = await deployer.getAddress();
    const net = await ethers.provider.getNetwork();
    const chainId = net.chainId.toString();

    console.log(`Network: ${networkName} (chainId=${chainId})`);
    console.log(`Deployer: ${deployerAddr}`);

    // Deploys Implementation(template contract)
    console.log("Deploying Implementation...");
    const implementation = await ethers.deployContract("Implementation", [], deployer);
    const implTx = implementation.deploymentTransaction();
    await implementation.waitForDeployment();
    const implementationAddr = await implementation.getAddress();
    console.log(`Implementation: ${implementationAddr} tx=${implTx?.hash ?? "null"}`);

    // Deployes VaultFactory(Implementation)
    console.log("Deploying VaultFactory...");
    const factory = await ethers.deployContract("VaultFactory", [implementationAddr], deployer);
    const factoryTx = factory.deploymentTransaction();
    await factory.waitForDeployment();
    const factoryAddr = await factory.getAddress();
    console.log(`VaultFactory: ${factoryAddr} tx=${factoryTx?.hash ?? "null"}`);

    const repoRoot = path.resolve(process.cwd(), "..");
    const deploymentsDir = path.join(repoRoot, "deployments");
    fs.mkdirSync(deploymentsDir, { recursive: true });

    const outPath = path.join(deploymentsDir, "sepolia.hardhat.v0.1.1-fix.json");

    const payload: DeploymentJson = {
        network: networkName,
        chainId,
        deployedAt: new Date().toISOString(),
        deployer: deployerAddr,
        contracts: {
            Implementation: { address: implementationAddr, txHash: implTx?.hash ?? null },
            VaultFactory: {
                address: factoryAddr,
                txHash: factoryTx?.hash ?? null,
                constructorArgs: [implementationAddr],
            },
        },
    };
    
    fs.writeFileSync(outPath, JSON.stringify(payload, null, 2));
    console.log(`Wrote deployment file: ${outPath}`);
    
    console.log("\nNEXT (verify):");
    console.log(`pnpm -C hardhat verify:sepolia ${implementationAddr}`);
    console.log(`pnpm -C hardhat verify:sepolia ${factoryAddr} ${implementationAddr}`);
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
