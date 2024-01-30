## High

### [H-1] Erroneous `AssetToken::updateExchangeRate` call in `ThunderLoan::deposit` causes exchange rate to be incorrect resulting in liquidity providers being unable to withdraw funds.

**Description** In the ThunderLoan system, the `AssetToken::s_exchangeRate` is responsible for keeping track of the exchange rate between assetTokens and underlying tokens. In a way, it's responsible for keeping track of fees earned by completing flash loans.

The `ThunderLoan::deposit` function updates this rate, without collecting any fees. 

```javascript

    function deposit(IERC20 token, uint256 amount) external revertIfZero(amount) revertIfNotAllowedToken(token) {
        AssetToken assetToken = s_tokenToAssetToken[token];
        uint256 exchangeRate = assetToken.getExchangeRate();
        uint256 mintAmount = (amount * assetToken.EXCHANGE_RATE_PRECISION()) / exchangeRate;
        emit Deposit(msg.sender, token, amount);
        assetToken.mint(msg.sender, mintAmount);
@>      uint256 calculatedFee = getCalculatedFee(token, amount);
@>      assetToken.updateExchangeRate(calculatedFee);
        token.safeTransferFrom(msg.sender, address(assetToken), amount);
    }
```

**Impact**

`ThunderLoan::redeem` is blocked because the protocol thinks more fees have been collected than in reality. It therefore attempts to issue the liquidity provider more funds than they're actually owed. For the last liquidity provider to call redeem, they won't be able to get all of their tokens.

**Proof of Concept**

1. LP deposits
2. User completes a flash loan
3. It is now impossible for LP to redeem

Place the following test into `ThunderLoanTest.t.sol`:

<details>
<summary> POC </summary>

```javascript
    function testRedemptionAfterLoan() public setAllowedToken hasDeposits {
        //Perform a flash loan
        uint256 amountToBorrow = AMOUNT * 10;
        uint256 calculatedFee = thunderLoan.getCalculatedFee(tokenA, amountToBorrow);
        console2.log("calculatedFee: ", calculatedFee);

        vm.startPrank(user);
        tokenA.mint(address(mockFlashLoanReceiver), calculatedFee);
        thunderLoan.flashloan(address(mockFlashLoanReceiver), tokenA, amountToBorrow, "");
        vm.stopPrank();

        //Check the exchange rate
        AssetToken asset = thunderLoan.getAssetFromToken(tokenA);
        console2.log("asset.getExchangeRate():", asset.getExchangeRate());

        //Redeem funds
        uint256 amountToRedeem = type(uint256).max; // redeem all their funds
        vm.startPrank(liquidityProvider);
        thunderLoan.redeem(tokenA, amountToRedeem);
        vm.stopPrank();
    }
```
</details>


**Recommended Mitigation** Remove the lines which incorrectly update the exchange rate in `ThunderLoan::deposit`

```diff
    function deposit(IERC20 token, uint256 amount) external revertIfZero(amount) revertIfNotAllowedToken(token) {
        AssetToken assetToken = s_tokenToAssetToken[token];
        uint256 exchangeRate = assetToken.getExchangeRate();
        uint256 mintAmount = (amount * assetToken.EXCHANGE_RATE_PRECISION()) / exchangeRate;
        emit Deposit(msg.sender, token, amount);
        assetToken.mint(msg.sender, mintAmount);
-       uint256 calculatedFee = getCalculatedFee(token, amount);
-       assetToken.updateExchangeRate(calculatedFee);
        token.safeTransferFrom(msg.sender, address(assetToken), amount);
    }

```