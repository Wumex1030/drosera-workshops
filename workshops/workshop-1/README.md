# LargeTransferTrap

A Drosera Trap that monitors a specific ERC20 token balance for a target wallet address and triggers when a large transfer occurs.

## How It Works
- `collect()` fetches the latest token balance of the monitored address.
- `shouldRespond()` compares the latest and previous balances.
- If the absolute difference is greater than or equal to `TRANSFER_THRESHOLD`, the trap responds with `"Large transfer detected"`.

## Hardcoded Values
- **TOKEN** — The ERC20 token contract address (replace before deployment)
- **TARGET** — The monitored wallet address (replace before deployment)
- **TRANSFER_THRESHOLD** — The minimum balance change (in token units) to trigger

## Deploying to Drosera
Drosera does not allow constructor arguments. All values are hardcoded in the contract.

## Running Tests
```bash
forge install
forge test
