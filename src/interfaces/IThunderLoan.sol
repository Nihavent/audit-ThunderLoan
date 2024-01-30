// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// @audit-info the IThunderLoan contract should be implemented by the ThunderLoan contract
// @audit-info different data type in param 1 of this function
interface IThunderLoan {
    function repay(address token, uint256 amount) external;
}
