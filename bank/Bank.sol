// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

import "../rolemanager/Administered.sol";
import "./IBank.sol";

/**
 * @author Taurai Ushewokunze 
 */


contract Bank is Administered, IBank  { 
    
    struct Deposit { 
        uint256 amount; 
        address payable payer; 
        address contractAddress; 
        string contractFunction; 
        uint256 timestamp; 
    }

    struct Withdrawal  {
        uint256 withdrawalAmount;
        uint256 timestamp; 
        address coAddress; 
        address aAddress; 
    }

    address payable cashoutAddress; 
    uint256 cashoutAddressSetTime; 

    mapping(string=>Deposit) depositsByDepositHash;
    mapping(string=>Withdrawal) withdrawalsByWithdrawalHash; 
    string [] withdrawalHashs;     


    constructor(address payable _administrator) Administered(_administrator) {
        cashoutAddress = _administrator; 
        cashoutAddressSetTime = block.timestamp; 
    }
    
    function deposit(uint256 _amount, address payable _payer, address _contractAddress, string memory _contractFunction, uint256 _timestamp) override payable external returns (string memory _depostHash) {
        Deposit memory l_deposit = Deposit ({
                                            amount : _amount,
                                            payer : _payer,
                                            contractAddress : _contractAddress, 
                                            contractFunction : _contractFunction,
                                            timestamp : _timestamp
                                        });
        bytes32 depositHash = keccak256(abi.encode(l_deposit));
        string memory hash = bytes32ToString(depositHash);
        depositsByDepositHash[hash] = l_deposit; 
        return hash; 
    }
    
    function withdraw(uint256 _amount) override external returns (string memory _withdrawalHash) {
        administratorOnly();
        require(fundsAvailable(_amount), 'insufficient funds available');
        Withdrawal memory withdrawal = Withdrawal({
                                            withdrawalAmount : _amount, 
                                            timestamp : block.timestamp, 
                                            coAddress : cashoutAddress,
                                            aAddress : administrator 
                                           });
        bytes32 withdrawalHash = keccak256(abi.encode(withdrawal));                                  
        string memory hash = bytes32ToString(withdrawalHash);
      
        withdrawalsByWithdrawalHash[hash] = withdrawal;
        withdrawalHashs.push(hash);
        cashoutAddress.transfer(_amount);
        return hash; 
    }

    function refund(string memory _depositHash) override external returns (uint256 _refundedAmount, 
                                                                           address _originalPayer, 
                                                                           address _originalContractAddress, 
                                                                           string memory _originalContractFunction, 
                                                                           uint256 _originalTime) {
        administratorOnly();
        Deposit memory l_deposit =  depositsByDepositHash[_depositHash];
        require(fundsAvailable(l_deposit.amount), 'insufficient funds available');
        l_deposit.payer.transfer(l_deposit.amount);
        return (l_deposit.amount, l_deposit.payer, l_deposit.contractAddress, l_deposit.contractFunction, l_deposit.timestamp);
    }
    
    function fundsAvailable(uint256 _amount) internal view returns (bool _available) {
        uint256 bal = address(this).balance; 
        if(bal > _amount) {
            return true; 
        }
        return false; 
    }
    
    function getBalance() override external view returns (uint256 _totalBankBalance) {
        return (address(this).balance); 
    }

    function getCashoutAddress() override external view returns (address _cashoutAddress, uint256 _timeSet) {
        administratorOnly();
        return (cashoutAddress, cashoutAddressSetTime); 
    }
    
    function setCashoutAddress(address payable _cashoutAddress) override external returns (bool _set) {
        administratorOnly();
        cashoutAddress = _cashoutAddress; 
        cashoutAddressSetTime = block.timestamp; 
        return true; 
    }
    
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory _str) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}