// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MyTokenERC20.sol";

contract MyTokenTestERC20 is Test {
    MyTokenERC20 myToken;
    address owner;
    address addr1;
    address addr2;

    uint256 initialTokensPerEther = 100;
    uint256 initialFeePercentage = 2;

    function setUp() public {
        owner = address(this);
        addr1 = address(vm.addr(1));
        addr2 = address(vm.addr(2));
        myToken = new MyTokenERC20(owner, initialTokensPerEther, initialFeePercentage);
    }

    function testDeployment() public view {
        assertEq(myToken.owner(), owner);
        assertEq(myToken.tokensPerEther(), initialTokensPerEther);
        assertEq(myToken.feePercentage(), initialFeePercentage);
    }

    function testBuy() public payable {
        vm.deal(addr1, 1);
        vm.prank(addr1);
        myToken.buy{value: 1}();

        assertEq(myToken.balanceOf(addr1), initialTokensPerEther);
    }

    function testBuyNoEthFails() public {
        vm.prank(addr1);
        vm.expectRevert("Send ETH to purchase tokens");
        myToken.buy();
    }

    function testTransferWithFee() public {
        vm.deal(addr1, 1);
        vm.prank(addr1);
        myToken.buy{value: 1}();

        uint256 transferAmount = 10;
        uint256 fee = (transferAmount * initialFeePercentage) / 100;
        uint256 ownerBalance = myToken.balanceOf(owner);

        vm.prank(addr1);
        myToken.transfer(addr2, transferAmount);

        assertEq(myToken.balanceOf(addr1), initialTokensPerEther - transferAmount);
        assertEq(myToken.balanceOf(addr2), transferAmount);
        assertEq(myToken.balanceOf(owner), ownerBalance + fee);
    }

    function testTransferFromWithFee() public {
        vm.deal(addr1, 1);
        vm.prank(addr1);
        myToken.buy{value: 1}();
        vm.prank(addr1);
        myToken.approve(addr2, 50);

        uint256 ownerBalance = myToken.balanceOf(owner);

        uint256 transferAmount = 20;
        uint256 fee = (transferAmount * initialFeePercentage) / 100;

        vm.prank(addr2);
        myToken.transferFrom(addr1, addr2, transferAmount);

        assertEq(myToken.balanceOf(addr1), initialTokensPerEther - transferAmount);
        assertEq(myToken.balanceOf(addr2), transferAmount);
        assertEq(myToken.balanceOf(owner), ownerBalance + fee);
        assertEq(myToken.allowance(addr1, addr2), 30);
    }

    function testUpdateFeePercentage() public {
        myToken.setFeePercentage(5);
        assertEq(myToken.feePercentage(), 5);
    }

    function testUpdateTokensPerEther() public {
        myToken.setTokensPerEther(200);
        assertEq(myToken.tokensPerEther(), 200);
    }

    function testPermit() public
    {
        uint256 nonce = myToken.nonces(addr1);
        uint256 deadline = block.timestamp + 30 minutes;
        uint256 allowance = 100;

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                addr1,
                addr2,
                allowance,
                nonce,
                deadline
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked("\x19\x01", myToken.DOMAIN_SEPARATOR(), structHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        myToken.permit(addr1, addr2, allowance, deadline, v, r, s);
        assertEq(myToken.allowance(addr1, addr2), allowance);
        myToken.transfer(addr1, 200);

        uint256 addr1Balance = myToken.balanceOf(addr1);
        uint256 fee = (allowance * initialFeePercentage) / 100;

        vm.prank(addr2);
        myToken.transferFrom(addr1, addr2, allowance);

        assertEq(myToken.balanceOf(addr1), addr1Balance - allowance);
        assertEq(myToken.balanceOf(addr2), allowance - fee);
    }
}

