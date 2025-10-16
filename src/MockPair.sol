// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Simplified Uniswap-like Pair for testing liquidity monitoring
contract MockPair {
    uint112 private _reserve0;
    uint112 private _reserve1;
    uint32 private _blockTimestampLast;

    constructor(uint112 r0, uint112 r1) {
        _reserve0 = r0;
        _reserve1 = r1;
        _blockTimestampLast = uint32(block.timestamp);
    }

    function getReserves() external view returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    ) {
        return (_reserve0, _reserve1, _blockTimestampLast);
    }

    function updateReserves(uint112 newR0, uint112 newR1) external {
        _reserve0 = newR0;
        _reserve1 = newR1;
        _blockTimestampLast = uint32(block.timestamp);
    }
}
