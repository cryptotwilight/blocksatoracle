// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

interface IBank { 
    
    function deposit(uint256 _amount, address payable _payer, address _contractAddress, string memory _contractFunction, uint256 _time) payable external returns (string memory _depostHash);
    
    function withdraw(uint256 _amount) external returns (string memory withdrawalHash); 

    function refund(string memory _depositHash) external returns (uint256 _refundedAmount, address _originalPayer, address _originalContractAddress, string memory _originalContractFunction, uint256 _originalTime);
    
    function getBalance() external view returns (uint256 _totalBankBalance);

    function getCashoutAddress() external view returns (address _cashoutAddress, uint256 _timeSet);
    
    function setCashoutAddress(address payable _cashoutAddress) external returns (bool _set);
}