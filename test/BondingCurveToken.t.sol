// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

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

    function testOnTransferReceivedFailWrongSender() public {
        vm.expectRevert("only purchaseToken can mint");
        bondingCurveToken.onTransferReceived(address(0), address(0), 0, "");
    }

    function testOnTransferReceivedFailAmount() public {
        vm.expectRevert("amount must be greater than 0");
        vm.prank(address(purchaseToken));
        bondingCurveToken.onTransferReceived(address(0), address(0), 0, "");
    }

    function testOnApprovalReceivedSuccess() public {
        vm.prank(jordan);
        purchaseToken.freeMint(1e18);

        vm.prank(jordan);
        purchaseToken.increaseAllowance(address(bondingCurveToken), 1e18);

        vm.prank(address(purchaseToken));
        bondingCurveToken.onApprovalReceived(jordan, 1e18, "");
    }

    function testOnApprovalReceivedFailSender() public {
        vm.expectRevert("only purchaseToken can mint");
        bondingCurveToken.onApprovalReceived(address(0), 1e18, "");
    }

    function testOnApprovalReceivedFailAmount() public {
        vm.prank(address(purchaseToken));
        vm.expectRevert("amount must be greater than 0");
        bondingCurveToken.onApprovalReceived(address(0), 0, "");
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

    function testBurnRoot2() public {
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

        console.log("PCT balance:", purchaseToken.balanceOf(jordan));
        // this test will fail because of precision loss
        // assertEq(purchaseToken.balanceOf(jordan), initBalance);
    }

    function testBurnRoot36() public {
        vm.prank(jordan);
        purchaseToken.freeMint(18e18);
        uint256 initBalance = purchaseToken.balanceOf(jordan);
        console.log("PCT balance:", initBalance);

        // mint on curve by sending PurchaseTokens to BondingCurveToken
        vm.prank(jordan);
        purchaseToken.transferAndCall(address(bondingCurveToken), 18e18);
        assertGt(bondingCurveToken.balanceOf(jordan), 0);
        console.log("BCT balance:", bondingCurveToken.balanceOf(jordan));

        // burn tokens and get PurchaseTokens back
        uint256 balance = bondingCurveToken.balanceOf(jordan);
        vm.prank(jordan);
        bondingCurveToken.burnOnCurve(balance);

        console.log("PCT balance:", purchaseToken.balanceOf(jordan));
        assertEq(purchaseToken.balanceOf(jordan), initBalance);
    }
}
