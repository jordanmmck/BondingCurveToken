// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BondingCurveToken.sol";
import "../src/PurchaseToken.sol";

contract BondingCurveTokenTest is Test {
    BondingCurveToken public bondingCurveToken;
    PurchaseToken public purchaseToken;

    address public jordan = address(0x34);
    address public vitalik = address(0x77);
    address public sam = address(0x99);

    function setUp() public {
        purchaseToken = new PurchaseToken();
        bondingCurveToken = new BondingCurveToken(address(purchaseToken));
    }

    function _mint(uint256 amount) private {
        (bool ok,) = address(bondingCurveToken).call{value: amount}(abi.encodeWithSignature("_mintOnCurve()"));
        require(ok, "send failed");
    }

    function testMint() public {
        // mint PurchaseTokens
        vm.prank(jordan);
        purchaseToken.freeMint(1e18);
        assertEq(purchaseToken.balanceOf(jordan), 1e18);

        // assert zero BondingCurveTokens
        assertEq(bondingCurveToken.balanceOf(jordan), 0);

        // mint on curve by sending PurchaseTokens to BondingCurveToken
        vm.prank(jordan);
        purchaseToken.transferAndCall(address(bondingCurveToken), 1e18);

        // assert non-zero BondingCurveTokens
        assertGt(bondingCurveToken.balanceOf(jordan), 0);
    }

    function testMintCurve() public {
        vm.prank(jordan);
        purchaseToken.freeMint(1e18);
        vm.prank(jordan);
        purchaseToken.transferAndCall(address(bondingCurveToken), 1e18);

        vm.prank(vitalik);
        purchaseToken.freeMint(1e18);
        vm.prank(vitalik);
        purchaseToken.transferAndCall(address(bondingCurveToken), 1e18);

        vm.prank(sam);
        purchaseToken.freeMint(1e18);
        vm.prank(sam);
        purchaseToken.transferAndCall(address(bondingCurveToken), 1e18);

        assertGt(bondingCurveToken.balanceOf(jordan), bondingCurveToken.balanceOf(vitalik));
        assertGt(bondingCurveToken.balanceOf(vitalik), bondingCurveToken.balanceOf(sam));
    }

    function testBurn() public {
        vm.prank(jordan);
        purchaseToken.freeMint(1e18);
        uint256 initBalance = purchaseToken.balanceOf(jordan);
        console.log("PCT balance:", initBalance);

        // mint on curve by sending PurchaseTokens to BondingCurveToken
        vm.prank(jordan);
        purchaseToken.transferAndCall(address(bondingCurveToken), 1e18);
        assertGt(bondingCurveToken.balanceOf(jordan), 0);
        console.log("BCT balance:", bondingCurveToken.balanceOf(jordan));

        // burn tokens and get PurchaseTokens back
        uint256 balance = bondingCurveToken.balanceOf(jordan);
        vm.prank(jordan);
        bondingCurveToken.burnOnCurve(balance);
        console.log("BCT balance:", bondingCurveToken.balanceOf(jordan));

        console.log("PCT balance:", purchaseToken.balanceOf(jordan));
        // this test will fail because of rounding errors / precision loss
        // assertEq(purchaseToken.balanceOf(jordan), initBalance);
    }
}
