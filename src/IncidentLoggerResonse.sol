// src/IncidentLoggerResponse.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract IncidentLoggerResponse {
    event Incident(bytes data, uint256 blockNumber);

    function respondToIncident(bytes calldata incidentData) external {
        emit Incident(incidentData, block.number);
    }
}
