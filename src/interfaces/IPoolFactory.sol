// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.20;

// n probably the interface to work with poolFactory.sol from TSwap
interface IPoolFactory {
    function getPool(address tokenAddress) external view returns (address);
}
