// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BondingCurveToken.sol";

contract BondingCurveTokenTest is Test {
    BondingCurveToken public bondingCurveToken;
    address public jordan = address(0x34);
    address public vitalik = address(0x77);
    address public sam = address(0x99);

    function setUp() public {
        bondingCurveToken = new BondingCurveToken();
    }

    function _mint(uint256 amount) private {
        (bool ok, ) = address(bondingCurveToken).call{value: amount}(
            abi.encodeWithSignature("mintOnCurve()")
        );
        require(ok, "send failed");
    }

    function testMint() public {
        hoax(jordan, 1 ether);
        _mint(1 ether);

        hoax(vitalik, 1 ether);
        _mint(1 ether);

        hoax(sam, 1 ether);
        _mint(1 ether);

        assertGt(
            bondingCurveToken.balanceOf(jordan),
            bondingCurveToken.balanceOf(vitalik)
        );
        assertGt(
            bondingCurveToken.balanceOf(vitalik),
            bondingCurveToken.balanceOf(sam)
        );
    }

    function testBurn() public {
        // mint tokens
        hoax(jordan, 1 ether);
        _mint(1 ether);

        // burn tokens
        uint256 balance = bondingCurveToken.balanceOf(jordan);
        vm.prank(jordan);
        bondingCurveToken.burnOnCurve(balance);
    }

    function testProfitAndLoss() public {
        hoax(jordan, 1 ether);
        _mint(1 ether);
        hoax(vitalik, 1 ether);
        _mint(1 ether);

        uint256 jBalance = bondingCurveToken.balanceOf(jordan);
        vm.prank(jordan);
        bondingCurveToken.burnOnCurve(jBalance);

        // assert first buyer made profit
        assertGt(jordan.balance, 1 ether);

        uint256 vBalance = bondingCurveToken.balanceOf(vitalik);
        vm.prank(vitalik);
        bondingCurveToken.burnOnCurve(vBalance);

        // assert second buyer had loss
        assertLt(vitalik.balance, 1 ether);
    }
}
