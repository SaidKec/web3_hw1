// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "../src/MyTokenERC20.sol";
import "../src/MyTokenERC721.sol";
import "../src/MyTokenERC1155.sol";

contract MyTokensScript is Script {
    MyTokenERC20 myErc20Token;
    MyTokenERC721 myErc721Token;
    MyTokenERC1155 myErc1155Token;

    address erc20Address = 0x48d23e63547C0Bc14A7851667977Ac172F01c6Fe;
    address erc721Address = 0x96F995d5d9d9c623B771d086B2Be502daBa359bD;
    address erc1155Address = 0x1c1c9519d02C920624C5721034c088720F6644A3;
    address senderAddress = 0x6669C8645EEAaf04a777EF5278853090D0Fb8fc2;
    address recipientAddress = 0x6669C8645eEaaf04a777ef5278853090d0FB8Fc3;

    function setUp() public
    {
        myErc20Token = MyTokenERC20(erc20Address);
        myErc721Token = MyTokenERC721(erc721Address);
        myErc1155Token = MyTokenERC1155(erc1155Address);
    }

    function run() public
    {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        testMintERC20();
        testSafeMintERC721();
        testBuyERC1155();
        checkAllTokenBalances();
        testEventsFilter();

        vm.stopBroadcast();
    }


    function testMintERC20() internal {
        myErc20Token.buy{value: 0.05 ether}();

        myErc20Token.transfer(recipientAddress, 0.01 ether);

        myErc20Token.approve(senderAddress, 0.01 ether);
        myErc20Token.transferFrom(senderAddress, recipientAddress, 0.01 ether);
    }

    function testSafeMintERC721() internal {
        myErc721Token.buyToken{value: 0.01 ether}("https://amaranth-negative-orangutan-149.mypinata.cloud/ipfs/QmaBv8VWw5aHbDNxkRnE1gC6AJjwajkGGSSsAmzp9g6w6M");
    }


    function testBuyERC1155() internal {
        myErc1155Token.buyToken{value: 0.02 ether}(senderAddress, 1, 2);

        myErc1155Token.safeTransferFrom(senderAddress, recipientAddress, 1, 1, "");
    }

    function getERC20Balance(address user) internal view returns (uint256) {
        bytes32 slot = keccak256(abi.encode(user, 0));
        bytes32 balanceSlot;
        assembly {
            balanceSlot := sload(slot)
        }
        return uint256(balanceSlot);
    }

    function getERC1155Balance(address user, uint256 tokenId) internal view returns (uint256) {
        bytes32 slot = keccak256(abi.encode(user, keccak256(abi.encode(tokenId, 1))));
        bytes32 balanceSlot;
        assembly {
            balanceSlot := sload(slot)
        }
        return uint256(balanceSlot);
    }

    function checkAllTokenBalances() public view {
        console.log("MyTokenERC20:", getERC20Balance(senderAddress));
        console.log("MyTokenERC721:", myErc721Token.balanceOf(senderAddress));
        console.log("MyTokenERC1155:", getERC1155Balance(senderAddress, 1));
    }

    function testEventsFilter() internal {
        vm.recordLogs();
        myErc20Token.transfer(senderAddress, 0.01 ether);
        myErc1155Token.buyToken{value: 0.02 ether}(senderAddress, 1, 2);
        myErc1155Token.safeTransferFrom(senderAddress, recipientAddress, 1, 1, "");

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1;
        uint256[] memory amount = new uint256[](1);
        amount[0] = 1;
        myErc1155Token.safeBatchTransferFrom(senderAddress, recipientAddress, ids, amount, "");

        Vm.Log[] memory logs = vm.getRecordedLogs();
        filterTransferLogs(logs);
    }

    function printTransferLog(Vm.Log memory log) internal pure {
        console.log("Transfer event");
        address from = address(uint160(uint256(log.topics[1])));
        address to = address(uint160(uint256(log.topics[2])));
        console.log("From:", from);
        console.log("To:", to);

        uint256 value = abi.decode(log.data, (uint256));
        console.log("Value:", value);
    }

    function printTransferSingleLog(Vm.Log memory log) internal pure {
        address operator = address(uint160(uint256(log.topics[1])));
        address from = address(uint160(uint256(log.topics[2])));
        address to = address(uint160(uint256(log.topics[3])));
        (uint256 id, uint256 value) = abi.decode(log.data, (uint256, uint256));

        console.log("TransferSingle event. Operator ", operator);
        console.log("From", from, "To", to);
        console.log("Id", id, "Value", value);
    }

    function printTransferBatchLog(Vm.Log memory log) internal pure {
        address operator = address(uint160(uint256(log.topics[1])));
        address from = address(uint160(uint256(log.topics[2])));
        address to = address(uint160(uint256(log.topics[3])));
        (uint256[] memory ids, uint256[] memory values) = abi.decode(log.data, (uint256[], uint256[]));

        console.log("TransferBatch event. Operator ", operator);
        console.log("From", from, "To", to);
        for (uint256 i = 0; i < ids.length; i++) {
            console.log("Id:", ids[i], "Value:", values[i]);
        }
    }

    function filterTransferLogs(Vm.Log[] memory logs) internal pure {
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == keccak256("Transfer(address,address,uint256)")) {
                printTransferLog(logs[i]);
            } else if (logs[i].topics[0] == keccak256("TransferSingle(address,address,address,uint256,uint256)")) {
                printTransferSingleLog(logs[i]);
            } else if (logs[i].topics[0] == keccak256("TransferBatch(address,address,address,uint256[],uint256[])")) {
                printTransferBatchLog(logs[i]);
            }
        }
    }
}