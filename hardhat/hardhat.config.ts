import path from "node:path";
import { fileURLToPath } from "node:url";
import dotenv from "dotenv";

import { defineConfig } from "hardhat/config";
import hardhatToolbox from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import hardhatVerify from "@nomicfoundation/hardhat-verify";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config({ path: path.resolve(__dirname, "..", ".env") });

function mustEnv(name: string): string {
    const v = process.env[name];
    if (!v) throw new Error(`Missing env var: ${name}`);
    return v;
}

const SEPOLIA_RPC_URL = mustEnv("SEPOLIA_RPC_URL");
const PRIVATE_KEY = mustEnv("PRIVATE_KEY");
const ETHERSCAN_API_KEY = mustEnv("ETHERSCAN_API_KEY");

export default defineConfig({
    plugins: [hardhatToolbox, hardhatVerify],

    paths: {
        sources: path.resolve(__dirname, "contracts"),
        cache: path.resolve(__dirname, "cache"),
        artifacts: path.resolve(__dirname, "artifacts"),
    },

    solidity: {
        version: "0.8.30",
        settings: {
            optimizer: { enabled: true, runs: 200 }
        },
    },

    networks: {
        sepolia: {
            type: "http",
            chainType: "l1",
            url: SEPOLIA_RPC_URL,
            accounts: [PRIVATE_KEY],
        },
    },

    verify: {
        etherscan: {
            apiKey: ETHERSCAN_API_KEY
        },
    },
});