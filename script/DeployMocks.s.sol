// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MockToken.sol";
import "../src/MockPair.sol";

contract DeployMocks is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy mock tokens
        MockToken tokenA = new MockToken("MockA", "MA");
        MockToken tokenB = new MockToken("MockB", "MB");

        // Mint some liquidity
        tokenA.mint(msg.sender, 1_000_000 ether);
        tokenB.mint(msg.sender, 1_000_000 ether);

        // Deploy pair with initial reserves
        MockPair pair = new MockPair(500_000, 500_000);

        vm.stopBroadcast();

        console.log("TokenA:", address(tokenA));
        console.log("TokenB:", address(tokenB));
        console.log("MockPair:", address(pair));
    }
}
