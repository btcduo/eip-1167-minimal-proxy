#!/usr/bin/env bash
set -euo pipefail

mkdir -p out/logs

extract() {
  local src="$1"
  local dst="$2"

  rg -n "PASS|FAIL|Suite result|runs:|calls:|reverts:" "$src" \
    > "$dst"
}

# Invariant
forge test --match-path test/CloneFactory_Invariant.t.sol -vvv 2>&1 \
  | tee out/logs/invariant_vulnerable.log
extract out/logs/invariant_vulnerable.log \
        out/logs/invariant_vulnerable_excerpt.txt

# Happy
forge test --match-path test/CloneFactory_Happy.t.sol -vvv 2>&1 \
  | tee out/logs/happy_vulnerable.log
extract out/logs/happy_vulnerable.log \
        out/logs/happy_vulnerable_excerpt.txt

# Revert
forge test --match-path test/CloneFactory_Revert.t.sol -vvv 2>&1 \
  | tee out/logs/revert_vulnerable.log
extract out/logs/revert_vulnerable.log \
        out/logs/revert_vulnerable_excerpt.txt

# Fuzz
forge test --match-path test/CloneFactory_Fuzz.t.sol -vvv 2>&1 \
  | tee out/logs/fuzz_vulnerable.log
extract out/logs/fuzz_vulnerable.log \
        out/logs/fuzz_vulnerable_excerpt.txt

# PoC
forge test --match-path test/CloneFactory_PoC.t.sol -vvv 2>&1 \
  | tee out/logs/poc_vulnerable.log
extract out/logs/poc_vulnerable.log \
        out/logs/poc_vulnerable_excerpt.txt

# All tests
forge test -vvv 2>&1 | tee out/logs/test_all_vulnerable.log
extract out/logs/test_all_vulnerable.log \
        out/logs/test_all_vulnerable_excerpt.txt
