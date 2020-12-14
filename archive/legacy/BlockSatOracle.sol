// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.0 <0.7.4; 
pragma experimental ABIEncoderV2;

import "https://github.com/tellor-io/usingtellor/blob/master/contracts/UsingTellor.sol";
import "./IBSOEventListener.sol";

contract BlockSatOracle is UsingTellor { 
    
    struct Event { 
        string name;
        uint256 timestamp; 
    }
    
    address administrator; 
    
    mapping(string=>uint256) eventTimestampsByEventName; 
    Event [] eventRegistry;
    
    mapping(address=>address) listenerByOwnerAddress; 
    IBSOEventListener [] listeners; 
    
    
    constructor( address _administrator, 
                 address payable _tellorAddress) UsingTellor(_tellorAddress)public{
        administrator = _administrator;
    }
    
    
    function getOracleEventCount () external view returns (uint256 _count){
        _count = eventRegistry.length;
        
    }
    
    function getOracleEvents() external view returns (string[] memory _events) {
        _events = new string[](eventRegistry.length);
        for(uint x =0; x < eventRegistry.length; x++){
            _events[x] = eventRegistry[x].name; 
        } 
        return _events;
    }

    function getPriceOnEvent(string calldata _event, uint256 _currencyPairCode) external returns (uint256 _currencyPairPrice) {
        uint256 l_eventTimestamp = eventTimestampsByEventName[_event];
        bool ifRetrieve; 
        uint256 timestamp;
        (ifRetrieve, _currencyPairPrice, timestamp) = getDataBefore(_currencyPairCode, l_eventTimestamp);
        return  _currencyPairPrice;
        
    }
    
    function registerBSOEventListener(address _listener) external returns (bool _isRegistered) {
        IBSOEventListener listener = IBSOEventListener(_listener);
        listeners.push(listener);
        return true; 
    }
    
    
    function deregisterBSOEventListener(address _listener) external returns (bool _isDeRegistered){
        // @todo
    }
    
    function notifyListeners(Event memory _event) internal returns (bool _notified) {
        for(uint x=0; x < listeners.length; x++) {
            listeners[x].onEvent(_event.name, _event.timestamp);
        }
        return true; 
    }
    
    
    function registerEvent(string calldata _eventName, uint256 _timestamp)  external returns (bool _isRegistered) {
        administratorOnly(); 
        Event memory l_event = Event({ name : _eventName, timestamp : _timestamp});
        eventRegistry.push(l_event);
        eventTimestampsByEventName[_eventName] = _timestamp; 
        return true; 
    }
    
    function administratorOnly() internal view returns (bool) {
        require(msg.sender == administrator);
    }
    
}