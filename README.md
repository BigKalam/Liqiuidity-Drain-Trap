LiquidityDrainTrap.
The LiquidityDrainTrap monitors a UniswapV2-style liquidity pool on the Hoodi Testnet and detects when a significant portion of liquidity is suddenly removed from the pool.
This helps identify potential rug pulls, panic withdrawals, or large liquidity shifts that may impact token stability.

---

🧠 Concept
Liquidity pools store token pairs (reserve0 and reserve1) used for swaps.
When liquidity is drained — intentionally or due to market actions — both reserves decrease drastically.

This trap:
Collects the total liquidity (reserve0 + reserve1) at each sampling interval.
Compares the latest liquidity against the average of previous samples.
Triggers a signal if the liquidity has dropped beyond a configured threshold.

---

⚙️ Parameters
| Variable | Description | Example |
|-----------|-------------|----------|
| PAIR | The address of the UniswapV2-style pair contract | 0x80229D6A1eEF2D40341CFB8533BE59802DaEBCE1 |
| THRESHOLD_BPS | The drop threshold (in basis points) that triggers a response | 2000 (20%) |
| block_sample_size | The number of past observations used for averaging | 8 |

---

📜 Contract Overview
File: src/LiquidityDrainTrap.sol

collect()
Fetches the pool’s reserves and encodes the total liquidity as bytes.
