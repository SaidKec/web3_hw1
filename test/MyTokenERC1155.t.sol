// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyTokenERC1155.sol";

contract MyTokenTestERC1155 is Test
{
    MyTokenERC1155 token;
    uint256 tokenId = 1;
    address user1 = address(vm.addr(1));

    function setUp() public
    {
        token = new MyTokenERC1155();
    }

    function testBuyOneToken() public
    {
        uint256 price = 0.01 ether;

        token.buyToken{value: price}(user1, tokenId, 1);

        assertEq(token.balanceOf(user1, tokenId), 1);
    }

    function testBuyTokens() public
    {
        uint256 amount = 5;
        uint256 price = amount * 0.01 ether;

        token.buyToken{value: price}(user1, tokenId, amount);

        assertEq(token.balanceOf(user1, tokenId), amount);
    }

    function testBuyByLessPrice() public
    {
        uint256 amount = 5;
        uint256 price = amount * 0.001 ether;

        try token.buyToken{value: price}(user1, tokenId, amount)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }

    function testBuyByMoreProce() public
    {
        uint256 amount = 5;
        uint256 price = amount * 0.1 ether;

        try token.buyToken{value: price}(user1, tokenId, amount)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }
}