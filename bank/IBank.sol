// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @title Bank
 * @author Tony Kunz
 * @dev This contract provides a banking system for Block Sat 
 */ 
interface IBank { 
    /**
     * @dev this operation deposits the given amount into the bank along with descriptive information about the deposit. 
     * @param _amount deposited should equal 'msg.value'
     * @param _payer address of entity making the payment 
     * @param _contractAddress address of contract sending the payment 
     * @param _contractFunction name of the function sending the payment 
     * @param _time at which the payment was sent 
     * @return _depostHash hash that uniquely identifies this deposit
     */
    function deposit(uint256 _amount, address payable _payer, address _contractAddress, string memory _contractFunction, uint256 _time) payable external returns (string memory _depostHash);
    
    /**
     * @dev this operation withdraws the given amount from the bank. Withdrawing entity should have the necessary permissions assigned. 
     * @param _amount to be withdrawn 
     * @return _withdrawalHash hash that uniquely identifies this withdrawalHash
     */ 
    function withdraw(uint256 _amount) external returns (string memory _withdrawalHash); 

    /**
     * @dev this operation will refund a given deposit to the original 'payer' address 
     * @param _depositHash reference to the original deposit
     * @return _refundedAmount this will match the amount originally deposited 
     * @return _originalPayer the original payer of the deposit 
     * @return _originalContractAddress the original contract through which this deposit was triggered 
     * @return _originalContractFunction the original function call through which this refunded deposit was triggered 
     * @return _originalTime the original time of that this deposit was made. 
     */
    function refund(string memory _depositHash) external returns (uint256 _refundedAmount, address _originalPayer, address _originalContractAddress, string memory _originalContractFunction, uint256 _originalTime);
    
    /**
     * @dev this operation will return the current total balance of all deposits in the bank 
     * NOTE: sum of deposits may not match value held in contract ;)
     * @return _totalBankBalance sum of deposits held in bank
     */ 
    function getBalance() external view returns (uint256 _totalBankBalance);
}