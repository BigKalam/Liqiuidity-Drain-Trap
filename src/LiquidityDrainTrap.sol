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
    // Suppose we monitor total liquidity as sum of both reserves
    uint256 public constant THRESHOLD_BPS = 2000; // 20% drop threshold

    /// Collect the current total liquidity (reserve0 + reserve1)
    function collect() external view override returns (bytes memory) {
        (uint112 r0, uint112 r1, ) = IUniswapV2Pair(PAIR).getReserves();
        uint256 total = uint256(r0) + uint256(r1);
        return abi.encode(total);
    }

    /// Decide whether liquidity has dropped enough to trigger
    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool, bytes memory)
    {
        uint256 len = data.length;
        if (len < 2) {
            return (false, "");
        }
        // average of older ones (exclude newest)
        uint256 sum = 0;
        uint256 count = len - 1;
        for (uint256 i = 1; i < len; i++) {
            uint256 v = abi.decode(data[i], (uint256));
            sum += v;
        }
        if (count == 0) {
            return (false, "");
        }
        uint256 avg = sum / count;
        uint256 latest = abi.decode(data[0], (uint256));
        if (avg == 0) {
            return (false, "");
        }
        if (latest < avg) {
            uint256 diff = avg - latest;
            uint256 diffBps = (diff * 10000) / avg;
            if (diffBps >= THRESHOLD_BPS) {
                return (true, abi.encode(latest, avg, diffBps));
            }
        }
        return (false, "");
    }
}
