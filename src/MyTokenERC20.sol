// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title ERC20 Ownable Token with transfer functions
contract MyTokenERC20 is ERC20, ERC20Permit, Ownable {
    uint256 public tokensPerEther;
    uint256 public feePercentage;

    constructor(address initialOwner, uint256 _tokensPerEther, uint256 _feePercentage)
        ERC20("MyTokenERC20", "MTK20")
        ERC20Permit("MyTokenERC20")
        Ownable(initialOwner)
    {
        tokensPerEther = _tokensPerEther;
        feePercentage = _feePercentage;
        _mint(initialOwner, 1e24);
    }

    /// @notice Function to purchase tokens with ETH
    /// @dev The amount of tokens purchased is determined by msg.value
    function buy() external payable {
        require(msg.value > 0, "Send ETH to purchase tokens");

        uint256 tokensToMint = msg.value * tokensPerEther;
        _mint(msg.sender, tokensToMint);
    }

    /// @notice Transfer tokens with a fee
    /// @param recipient Address of the recipient
    /// @param amount Amount of tokens to transfer
    /// @return bool Success of the operation
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * feePercentage) / 100;
        uint256 amountAfterFee = amount - fee;

        _transfer(msg.sender, recipient, amountAfterFee);
        _transfer(msg.sender, owner(), fee);
        return true;
    }

    /// @notice Transfer tokens with a fee from another address
    /// @param sender Address of the sender
    /// @param recipient Address of the recipient
    /// @param amount Amount of tokens to transfer
    /// @return bool Success of the operation
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * feePercentage) / 100;
        uint256 amountAfterFee = amount - fee;

        _transfer(sender, recipient, amountAfterFee);
        _transfer(sender, owner(), fee);

        _approve(sender, msg.sender, allowance(sender, msg.sender) - amount);
        return true;
    }

    /// @notice Sets a new rate of tokens per ETH
    /// @param _tokensPerEther New rate
    function setTokensPerEther(uint256 _tokensPerEther) external onlyOwner {
        tokensPerEther = _tokensPerEther;
    }

    /// @notice Sets a new percentage for the fee
    /// @param _feePercentage New fee percentage
    function setFeePercentage(uint256 _feePercentage) external onlyOwner {
        feePercentage = _feePercentage;
    }
}
