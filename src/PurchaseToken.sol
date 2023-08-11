// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {ERC1363} from "@vittominacori/contracts/token/ERC1363/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PurchaseToken is ERC1363 {
    address public immutable owner;

    constructor() ERC20("PurchaseToken", "PCT") {
        owner = msg.sender;
    }

    function freeMint(uint256 amount) external {
        _mint(msg.sender, amount);
    }
}
