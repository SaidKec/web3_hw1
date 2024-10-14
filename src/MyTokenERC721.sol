// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title ERC721 Token with Metadata and Purchase function
contract MyTokenERC721 is ERC721URIStorage
{
    uint256 public pricePerToken = 0.01 ether;
    uint256 public tokenCounter;

    constructor() ERC721("MyToken721", "MTK721")
    {
        tokenCounter = 0;
    }

    /// @notice Enables users to buy an NFT by sending Ether
    /// @param tokenURI The URI that contains the metadata for the token
    function buyToken(string memory tokenURI) external payable
    {
        require(msg.value == pricePerToken, "Incorrect Ether value sent for one NFT");
        tokenCounter += 1;
        _mint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenURI);
    }
}