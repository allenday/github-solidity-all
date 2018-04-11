/// base.sol -- basic ERC20 implementation

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

pragma solidity ^0.4.13;

import "./ERC20.sol";
import "./Stoppable.sol";
import "./Math.sol";
import "./Token.sol";
import "./TokenData.sol";

contract TokenLogic is ERC20Events, Math, Stoppable {

    TokenData public data;
    Token public token;
    uint public tokensPerWei=3000;
    bool public presale = true;
    uint public icoStart=1503756000; // = Aug 26 2017 2pm GMT
    uint public icoEnd;   //1504188000 = Aug 31 2017 2pm GMT
    uint public icoSale; //the number of tokens sold during the ICO
    uint public maxIco = 90000000000000000000000000; // the maximum number of tokens sold during ICO

    address[] contributors;

    function TokenLogic(Token token_, TokenData data_, uint icoStart_, uint icoHours_) {
        require(token_ != Token(0x0));

        if(data_ == address(0x0)) {
            data = new TokenData(this, 120000000000000000000000000, msg.sender);
        } else {
            data = data_;
        }
        token = token_;
        icoStart = icoStart_;
        icoEnd = icoStart + icoHours_ * 3600;
    }

    modifier tokenOnly {
        assert(msg.sender == address(token) || msg.sender == address(this));
        _;
    }

    function contributorCount() constant returns(uint) {
        return contributors.length;
    }

    function setOwner(address owner_) tokenOnly {
        owner = owner_;
        LogSetOwner(owner);
        data.setOwner(owner);
    }

    function setToken(Token token_) auth {
        token = token_;
    }

    function setIcoStart(uint icoStart_, uint icoHours_) auth {
        icoStart = icoStart_;
        icoEnd = icoStart + icoHours_ * 3600;
    }

    function setPresale(bool presale_) auth {
        presale = presale_;
    }

    function setTokensPerWei(uint tokensPerWei_) auth {
        require(tokensPerWei_ > 0);
        tokensPerWei = tokensPerWei_;
    }

    function totalSupply() constant returns (uint256) {
        return data.supply();
    }

    function balanceOf(address src) constant returns (uint256) {
        return data.balances(src);
    }

    function allowance(address src, address guy) constant returns (uint256) {
        return data.approvals(src, guy);
    }
    
    function transfer(address src, address dst, uint wad) tokenOnly returns (bool) {
        require(balanceOf(src) >= wad);
        
        data.setBalances(src, sub(data.balances(src), wad));
        data.setBalances(dst, add(data.balances(dst), wad));
        
        return true;
    }
    
    function transferFrom(address src, address dst, uint wad) tokenOnly returns (bool) {
        require(data.balances(src) >= wad);
        require(data.approvals(src, dst) >= wad);
        
        data.setApprovals(src, dst, sub(data.approvals(src, dst), wad));
        data.setBalances(src, sub(data.balances(src), wad));
        data.setBalances(dst, add(data.balances(dst), wad));
        
        return true;
    }
    
    function approve(address src, address guy, uint256 wad) tokenOnly returns (bool) {

        data.setApprovals(src, guy, wad);
        
        Approval(src, guy, wad);
        
        return true;
    }

    function mint(uint128 wad) tokenOnly {
        data.setBalances(owner, add(data.balances(owner), wad));
        data.setSupply(add(data.supply(), wad));
    }

    function burn(address src, uint128 wad) tokenOnly {
        require(balanceOf(src) >= wad);
        data.setBalances(src, sub(data.balances(src), wad));
        data.setSupply(sub(data.supply(), wad));
    }

    function returnIcoInvestments(uint contributorIndex) auth {
        /*this can only be done after the ICO close date and if less than 20mio tokens were sold*/
        require(now > icoEnd && icoSale < 20000000000000000000000000);

        address src = contributors[contributorIndex];
        require(src != address(0));

        uint srcBalance = balanceOf(src);

        /*transfer the sent ETH amount minus a 5 finney (0.005 ETH ~ 1USD) tax to pay for Gas*/
        token.transferEth(src, sub(div(srcBalance, tokensPerWei), 5 finney));

        /*give back the tokens*/
        data.setBalances(src, sub(data.balances(src), srcBalance));
        data.setBalances(owner, add(data.balances(owner), srcBalance));
        token.triggerTansferEvent(src, owner, srcBalance);

        /*reset the address after the transfer to avoid errors*/
        contributors[contributorIndex] = address(0);
    }

    function handlePayment(address src, uint eth) tokenOnly returns (uint){
        require(eth > 0);
        /*the time stamp has to be between the start and end times of the ICO*/
        require(now >= icoStart && now <= icoEnd);
        /*no more than 90 mio tokens shall be sold in the ICO*/
        require(icoSale < maxIco);

        uint tokenAmount = mul(tokensPerWei, eth);
        if (!presale) {
            //first 168 hours
            if (now < icoStart + (168 * 3600)) {
                tokenAmount = tokenAmount * 150 / 100;
            }
            //168 to 312 hours
            else if (now < icoStart + (312 * 3600)) {
                tokenAmount = tokenAmount * 130 / 100;
            }
            //312 to 456 hours
            else if (now < icoStart + (456 * 3600)) {
                tokenAmount = tokenAmount * 110 / 100;
            }
        }

        icoSale += tokenAmount;
        if(icoSale > maxIco) {
            uint excess = sub(icoSale, maxIco);
            tokenAmount = sub(tokenAmount, excess);
            token.transferEth(src, div(excess, tokensPerWei));
            icoSale = maxIco;
        }

        require(balanceOf(owner) >= tokenAmount);

        data.setBalances(owner, sub(data.balances(owner), tokenAmount));
        data.setBalances(src, add(data.balances(src), tokenAmount));
        contributors.push(src);

        token.triggerTansferEvent(owner, src, tokenAmount);

        return tokenAmount;
    }
}
