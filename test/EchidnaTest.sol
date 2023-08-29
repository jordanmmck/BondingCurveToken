// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../src/BondingCurveToken.sol";
import "../src/PurchaseToken.sol";

contract EchidnaTest {
    address public echidna = msg.sender;

    PurchaseToken public purchaseToken;
    BondingCurveToken public bondToken;

    address public purchaseTokenAddress;
    address public bondTokenAddress;

    constructor() {
        purchaseToken = new PurchaseToken();
        purchaseTokenAddress = address(purchaseToken);

        bondToken = new BondingCurveToken(purchaseTokenAddress);
        bondTokenAddress = address(bondToken);
    }

    event Log(uint256 pctBefore, uint256 pctAfter);

    function mintAndBurn(uint256 mintAmount) public {
        mintAmount = mintAmount + 1e15;

        purchaseToken.freeMint(mintAmount);
        purchaseToken.approve(bondTokenAddress, mintAmount);
        uint256 initialPCTBalance = purchaseToken.balanceOf(address(this));

        // mint
        purchaseToken.transferAndCall(bondTokenAddress, initialPCTBalance);

        // burn
        uint256 bondTokenBalance = bondToken.balanceOf(address(this));
        bondToken.burnOnCurve(bondTokenBalance);
        uint256 finalPCTBalance = purchaseToken.balanceOf(address(this));

        // assert post-condition
        emit Log(initialPCTBalance, finalPCTBalance);
        uint256 ratio = (initialPCTBalance * 1e9) / finalPCTBalance;
        assert(ratio - 1e9 < 100);
    }
}
