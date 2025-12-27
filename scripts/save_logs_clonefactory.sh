#!/usr/bin/env bash
set -euo pipefail

extract() {
  local src="$1"
  local dst="$2"

  rg -n "PASS|FAIL|Suite result|runs:|calls:|reverts:" "$src" \
    > "$dst"
}

# Invariant
forge test --match-path test/CloneFactory_Invariant.t.sol -vvv 2>&1 \
  | tee artifacts/logs/invariant.log
extract artifacts/logs/invariant.log \
        artifacts/logs/invariant_excerpt.txt

# Happy
forge test --match-path test/CloneFactory_Happy.t.sol -vvv 2>&1 \
  | tee artifacts/logs/happy.log
extract artifacts/logs/happy.log \
        artifacts/logs/happy_excerpt.txt

# Revert
forge test --match-path test/CloneFactory_Revert.t.sol -vvv 2>&1 \
  | tee artifacts/logs/revert.log
extract artifacts/logs/revert.log \
        artifacts/logs/revert_excerpt.txt

# Fuzz
forge test --match-path test/CloneFactory_Fuzz.t.sol -vvv 2>&1 \
  | tee artifacts/logs/fuzz.log
extract artifacts/logs/fuzz.log \
        artifacts/logs/fuzz_excerpt.txt

# PoC-Fixed
forge test --match-path test/CloneFactory_PoC_Fixed.t.sol -vvv 2>&1 \
  | tee artifacts/logs/poc.log
extract artifacts/logs/poc.log \
        artifacts/logs/poc_excerpt.txt

# All tests
forge test -vvv 2>&1 | tee artifacts/logs/test_all.log
extract artifacts/logs/test_all.log \
        artifacts/logs/test_all_excerpt.txt
