pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

interface IBSO {
    
    function getPriceOnEvent(string memory _currencyPair) external view returns (uint256 _price);

    function getListnerRegistrationFees() external view returns (string[] memory _categories, uint256[] memory _fees);
    
    function registerNaturalEventListener(string memory _name, address _address, uint256 _fee, uint _eventCount, string[] memory categories) payable external  returns (bool _success);

    function deregisterNaturalEventListener(string memory _name, address _address) external view returns(uint256 _refund, uint _deregisteredListenerCount);
}