// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

enum Type {
    ERC20,
    ERC721,
    ERC1155
}

enum Name {
    COIN,
    NFT,
    MINE,
    STAKE,
    LEND,
    BORROW,
    LIQUIDITY,
    FARM,
    BETTING_MARKET,
    CLAIM
}

enum Action {
    CLAIM,
    SEND,
    RECEIVE,
    MINT,
    BURN,
    VOTE,
    DELEGATE,
    COLLECT,
    APPROVE,
    REVOKE,
    SWAP,
    BORROW,
    REPAY,
    DEPOSIT_FIAT,
    PAUSE_FIAT,
    WITHDRAW_FIAT,
    DEPOSIT_STAKE,
    PAUSE_STAKE,
    WITHDRAW_STAKE,
    DEPOSIT_LOAN,
    PAUSE_LOAN,
    WITHDRAW_LOAN,
    DEPOSIT_LIQUIDITY,
    PAUSE_LIQUIDITY,
    WITHDRAW_LIQUIDITY,
    DEPOSIT_FARM,
    PAUSE_FARM,
    WITHDRAW_FARM
}

struct Balance {
    string name;
    string symbol;
    uint8 decimals;
    uint256 index;
    uint256 balance;
    address tokenAddress;
    Type tokenType;
}

struct TokenSet {
    Name name;
    Balance[] inputs;
    Balance[] outputs;
    Action[] actions;
}
