// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract BondingCurveToken is ERC20 {
    constructor() ERC20("BondingCurveToken", "BCT") {
        this;
    }

    function mintOnCurve() external payable {
        uint256 startSupply = totalSupply();
        uint256 endSupply = Math.sqrt(
            2 * msg.value + startSupply * startSupply
        );
        uint256 mintAmount = endSupply - startSupply;

        _mint(msg.sender, mintAmount);
    }

    function burnOnCurve(uint256 amount) public {
        uint256 startSupply = totalSupply();

        _burn(msg.sender, balanceOf(msg.sender));

        uint256 endSupply = startSupply - amount;
        uint256 ethOwing = (startSupply * startSupply - endSupply * endSupply) /
            2;

        payable(msg.sender).transfer(ethOwing);
    }
}
