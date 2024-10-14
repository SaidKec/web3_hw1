// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyTokenERC721.sol";

contract MyTokenTestERC721 is Test
{
    MyTokenERC721 myToken;
    string tokenLink = "https://amaranth-negative-orangutan-149.mypinata.cloud/ipfs/QmaBv8VWw5aHbDNxkRnE1gC6AJjwajkGGSSsAmzp9g6w6M";

    function setUp() public
    {
        myToken = new MyTokenERC721();
    }

    function testBuyToken() public
    {
        myToken.buyToken{value: myToken.pricePerToken()}(tokenLink);

        assertEq(myToken.ownerOf(1), address(this));
        assertEq(myToken.tokenURI(1), tokenLink);
    }

    function testBuyByLessPrice() public
    {
        try myToken.buyToken{value: myToken.pricePerToken() - 0.001 ether}(tokenLink)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }

    function testBuyByMorePrice() public
    {
        try myToken.buyToken{value: myToken.pricePerToken() + 0.001 ether}(tokenLink)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }
}