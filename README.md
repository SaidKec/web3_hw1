# WEB3 HW1 Абдуллин Саид

## Ссылки на контракты в обозревателе
  
ERC20  https://amoy.polygonscan.com/address/0x48d23e63547c0bc14a7851667977ac172f01c6fe

ERC721 https://amoy.polygonscan.com/address/0x96f995d5d9d9c623b771d086b2be502daba359bd

ERC1155 https://amoy.polygonscan.com/address/0x1c1c9519d02c920624c5721034c088720f6644a3

## Ответы на вопросы

1) Approve - функция стандарта ERC20, которая позволяет владельцу токенов дать разрешение на пользование определенным числом своих токенов другому контракту(например пользователю). Это может пригодиться для сценариев совершения транзакций от имени владельца токенов. В данной работе взаимодействие с approve используется для реализации функции transferFrom и в тестах.
2) Главное различие ERC721 и ERC1155 в том, что ERC721 предназначен для работы с уникальными токенами(NFT), у которых нет копий(т.к. все Id различны), ERC1155 позволяет создавать взаимозаменяемые токены.
3) SBT токен - токен, который невозможно передавать или продавать. То есть он изначально за кем-то или чем-то "закреплен", поэтому SBT токены можно использовать для различных сертификатов(например об прохождении курсов) или просто отмечать неизменяемые атрибуты сущности, за которой закреплен токен.
4) Создать SBT токен можно на основе ERC721 или ERC1155, переопределив возможные функции передачи токена. Например для простой функции transfer
```solidity
function transfer(address to, uint256 tokenId) public {
    revert("SBT can't be transfered");
}
```

## Комментарии по работе и скриншоты

Реализованы все 3 токена и сделаны тесты к ним. Сделан скрипт для работы с уже развернутыми в сети контрактами.

Сами контракты можно задеплоить в сеть командами

ERC20
```
forge create --constructor-args $OWNER_ADRESS $TOKENS_PER_ETHER $FEE --rpc-url $RPC_URL \                                                                
  --private-key $PRIVATE_KEY \
  src/MyTokenERC20.sol:MyTokenERC20 \
  --etherscan-api-key $ETHERSCAN_API_KEY --verify
```

ERC721
```
forge create --rpc-url $RPC_URL \                                                                
  --private-key $PRIVATE_KEY \
  src/MyTokenERC721.sol:MyTokenERC721 \
  --etherscan-api-key $ETHERSCAN_API_KEY --verify
```

ERC1155
```
forge create --rpc-url $RPC_URL \                                                                
  --private-key $PRIVATE_KEY \
  src/MyTokenERC1155.sol:MyTokenERC1155 \
  --etherscan-api-key $ETHERSCAN_API_KEY --verify
```

![image](https://github.com/user-attachments/assets/7ef1c25d-6336-4ce1-95c1-0e51638ce06f)
![image](https://github.com/user-attachments/assets/b724dd94-5ba3-46d1-b1d6-5f36f264496d)

