// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
}

contract LiquidityDrainTrap is ITrap {
    address public constant PAIR = 0x36D79fbD9F66f5FCd25E5c3C2305cd04c596B73a;
    uint256 public constant THRESHOLD_BPS = 2000; // 20% drop threshold

    /// Collect liquidity metric (planner-safe)
    function collect() external view override returns (bytes memory) {
        uint256 metric = 0;
        // Prevent revert if PAIR is missing / not yet deployed / static call blocked
        try IUniswapV2Pair(PAIR).getReserves() returns (uint112 r0, uint112 r1, uint32) {
            // Use min(r0, r1) instead of r0+r1 to reduce noise from price movement
            uint256 a = uint256(r0);
            uint256 b = uint256(r1);
            metric = a < b ? a : b;
        } catch {
            // metric stays 0 (safe no-op)
        }
        return abi.encode(metric);
    }

    /// Decide whether liquidity has dropped significantly
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        uint256 len = data.length;
        if (len < 2 || data[0].length < 32) return (false, "");

        uint256 sum = 0;
        uint256 count = 0;

        // average previous data points (ignore newest)
        for (uint256 i = 1; i < len; i++) {
            if (data[i].length < 32) continue; // skip empty blobs safely
            sum += abi.decode(data[i], (uint256));
            count++;
        }

        if (count == 0) return (false, "");

        uint256 avg = sum / count;
        if (avg == 0) return (false, "");

        uint256 latest = abi.decode(data[0], (uint256));
        if (latest >= avg) return (false, "");

        uint256 diff = avg - latest;
        uint256 diffBps = (diff * 10_000) / avg;

        if (diffBps >= THRESHOLD_BPS) {
            return (true, abi.encode(latest, avg, diffBps));
        }
        return (false, "");
    }
}
