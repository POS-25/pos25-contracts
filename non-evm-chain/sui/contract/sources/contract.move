// Copyright (c) 2023, Esollabs
// SPDX-License-Identifier: Apache-2.0
// A sui move contract for Pos
// 
module pos_contract::InZPos {

    use std::string::{String};
    use sui::tx_context::{Self, TxContext};
    use sui::event;
    use sui::coin::{Coin};
    use sui::pay::{Self};

    // Declares the address which the user will deposit money into this account.
    const STORE_BALANCE :address = @addr; 

    struct PosDeposit has copy,drop{
        fromAddress: address,
        amount: u64,
        callBackData: String   
    }

    /*
    The 'init' function is responsible for initializing the POS system.
    */ 
    fun init(_ctx : &mut TxContext){

    } 

    /* 
    The 'deposit' function is a public entry point that facilitates the deposit of a specified '_amount' of a given 'COINTYPE' token.
    @params
        '_coin': a mutable reference to a 'Coin' object,
        '_amount': the amount to deposit,
        '_callBackData': additional data for the deposit,
        'ctx': 'TxContext'.
    TODO:
    It initiates the deposit by calling 'pay::split_and_transfer', depositing '_amount' of the specified token into the `STORE_BALANCE`.
    The sender's address is retrieved using 'tx_context::sender(ctx)'.
    An 'PosDeposit' event is then emitted, recording the sender's address, the deposited amount, and any provided callback data.
    */
    public entry fun deposit<COINTYPE>( 
        _coin :&mut Coin<COINTYPE>,
        _amount : u64,
        _callBackData: String,
        ctx: &mut TxContext
    ){

        pay::split_and_transfer(_coin,_amount,STORE_BALANCE,ctx);

        let sender = tx_context::sender(ctx);
        
        event::emit(PosDeposit{
            fromAddress: sender,
            amount: _amount,
            callBackData: _callBackData
        });
    }

}