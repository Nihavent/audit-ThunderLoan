// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.20;

//@audit-info import only used in MockFlashLoanReceiver.sol, bad practice to import it here for a test
import { IThunderLoan } from "./IThunderLoan.sol";

/**
 * @dev Inspired by Aave:
 * https://github.com/aave/aave-v3-core/blob/master/contracts/flashloan/interfaces/IFlashLoanReceiver.sol
 */

// n no natspec
// qa the token the token which is being borrowed? yes
interface IFlashLoanReceiver {
    function executeOperation(
        address token,
        uint256 amount,
        uint256 fee,
        address initiator,
        bytes calldata params
    )
        external
        returns (bool);
}
