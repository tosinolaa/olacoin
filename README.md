# OLACOIN (Clarity / Clarinet)

A simple fungible token smart contract for Stacks, built with Clarinet. The token name is OLACOIN (symbol: OLA).

## Features
- Lightweight fungible token implementation (similar to SIP-010 interface)
- Owner-only mint and burn
- Standard `transfer`, `get-balance`, `get-total-supply`, `get-name`, `get-symbol`, `get-decimals`

## Prerequisites
- Linux with curl and tar available
- Node.js (optional, only if you want to manage Clarinet with npm)

## Project Structure
- `Clarinet.toml` — Clarinet project manifest
- `contracts/olacoin.clar` — Clarity smart contract
- `tests/` — Reserved for Clarinet tests (not added yet)

## Install Clarinet (local, no root)
This project uses a local binary for Clarinet so you don’t need system-wide installs. Run:

```bash
# Download the latest Clarinet Linux x86_64 binary from GitHub Releases
mkdir -p bin
curl -s https://api.github.com/repos/hirosystems/clarinet/releases/latest \
  | grep -Eo '"browser_download_url"\s*:\s*"[^"]+"' \
  | cut -d '"' -f4 \
  | grep -i -E 'linux.*(x86_64|amd64).*\.(tar\.gz|tgz|gz|zip|xz|tar)$' \
  | head -n1 \
  | xargs -I{} sh -c 'curl -L "{}" -o bin/clarinet-archive && \
      (file bin/clarinet-archive | grep -qiE "gzip|tar|zip" && \
        (mkdir -p bin/_extract && cd bin/_extract && tar -xzf ../clarinet-archive 2>/dev/null || unzip -o ../clarinet-archive) && \
        find bin/_extract -type f -name clarinet -exec mv {} ../clarinet \; && rm -rf bin/_extract) || \
      mv bin/clarinet-archive bin/clarinet';
chmod +x bin/clarinet
./bin/clarinet --version
```

If you prefer npm, you can also add Clarinet via npm scripts (note: a direct npm package may not be available in all environments):

```bash
npm init -y
# If an official npm package is available in your environment, install it and use `npx clarinet`.
```

## Build / Verify
From the project root:

```bash
./bin/clarinet check
```

You should see a successful type-check/analysis if everything compiles.

## Contract Overview
- Owner is set at deployment time to the deployer principal.
- `mint(recipient, amount)` — owner mints tokens to a principal; increases total supply.
- `burn(holder, amount)` — owner burns holder’s tokens; decreases total supply.
- `transfer(amount, sender, recipient)` — moves tokens from sender to recipient; requires `tx-sender == sender`.
- `get-balance(who)` — read-only; returns balance of `who`.
- `get-total-supply()` — read-only total supply.
- `get-name()/get-symbol()/get-decimals()` — read-only metadata.

## Try it in Clarinet Console
```bash
./bin/clarinet console
```
Then for example:

```clarity
# Replace ST... with your devnet principals shown by the console
(contract-call? .olacoin mint ST1... u1000)       ;; as contract owner
(contract-call? .olacoin transfer u100 ST1... ST2...)
(contract-call? .olacoin get-balance ST2...)
(contract-call? .olacoin get-total-supply)
```

## Notes
- This example is intentionally simple and does not import the formal SIP-010 trait file. You can extend it to `impl-trait` against SIP-010 if needed.
- Add tests under `tests/` using Clarinet’s test runner.
