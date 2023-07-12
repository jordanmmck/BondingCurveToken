// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363} from "@vittominacori/contracts/token/ERC1363/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {IERC1363Receiver} from "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";
import {IERC1363Spender} from "@openzeppelin/contracts/interfaces/IERC1363Spender.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract BondingCurveToken is ERC1363, IERC1363Receiver, IERC1363Spender {
    address public purchaseToken;

    constructor(address _purchaseToken) ERC20("BondingCurveToken", "BCT") {
        purchaseToken = _purchaseToken;
    }

    function onTransferReceived(address, address sender, uint256 amount, bytes calldata)
        external
        override
        returns (bytes4)
    {
        // operator should be same as _msgSender. should i use operator?
        require(_msgSender() == purchaseToken, "only purchaseToken can mint");
        require(amount > 0, "amount must be greater than 0");
        _mintOnCurve(sender, amount);

        // why do we return this?
        return IERC1363Receiver.onTransferReceived.selector;
    }

    function onApprovalReceived(address sender, uint256 amount, bytes calldata) external override returns (bytes4) {
        require(_msgSender() == purchaseToken, "only purchaseToken can mint");
        require(amount > 0, "amount must be greater than 0");

        // should i use require here, or check just that `true` is returned?
        require(IERC1363(purchaseToken).transferFrom(sender, address(this), amount), "transferFrom failed");
        _mintOnCurve(sender, amount);

        // why do we return this?
        return IERC1363Spender.onApprovalReceived.selector;
    }

    function _mintOnCurve(address sender, uint256 amount) private {
        uint256 supplyA = totalSupply();
        uint256 supplyB = Math.sqrt(2 * amount + supplyA * supplyA);
        uint256 mintAmount = supplyB - supplyA;

        _mint(sender, mintAmount);
    }

    // there seems to be a few ways we could handle the token burn:
    // have `onTransferReceived` check if the sender is this contract and if so, burn;
    // override `transferAndCall` and check if recipient is this contract, if so burn;
    // override `transfer` and check if recipient is this contract, if so burn;
    // or, just create a `burnOnCurve` function and have the user call that to burn;
    function burnOnCurve(uint256 amount) external returns (bool) {
        uint256 supplyB = totalSupply();

        _burn(msg.sender, amount);

        uint256 supplyA = supplyB - amount;
        uint256 tokensOwing = ((supplyB * supplyB) - (supplyA * supplyA)) / 2;

        return IERC1363(purchaseToken).transfer(msg.sender, tokensOwing);
    }
}
