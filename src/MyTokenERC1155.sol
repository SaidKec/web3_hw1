// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title ERC1155 Token with Metadata and Purchase function
contract MyTokenERC1155 is ERC1155
{
    uint256 public pricePerToken = 0.01 ether;

    constructor() ERC1155("https://amaranth-negative-orangutan-149.mypinata.cloud/ipfs/QmScdefaVvjEythhbAXbgomif43nRHvTLPHiKESp2d6mah") {}

    /// @notice Enables users to purchase a specific token by sending Ether
    /// @param id Token id
    /// @param amount The quantity of tokens
    function buyToken(address to, uint256 id, uint256 amount) external payable
    {
        require(msg.value == pricePerToken * amount, "Incorrect Ether value sent for one Token");
        _mint(to, id, amount, "");
    }
}