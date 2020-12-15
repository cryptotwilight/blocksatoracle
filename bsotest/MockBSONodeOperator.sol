// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <=0.8.0; 
pragma experimental ABIEncoderV2; 


import "../rolemanager/Administered.sol";
import "../blocksatoracle/BSOObjects.sol";
import "../blocksatoracle/IBSODispatch.sol";
/**
 * @title Mock Block Sat Node Operator 
 * @author Taurai Ushewokunze 
 * @dev This code mimics the behaviour of a data population node that harvests data off chain and posts it on chain.
 */ 
contract MockBSONodeOperator is Administered {

    mapping(string=>mapping(string=>address[])) addressToNotifyForCategoryByNaturalEventId;     
    
    mapping(string=>string) naturalEventPostingMessageByNaturalEventId;
    
    mapping(string=>NaturalEvent) naturalEventByNaturalEventId; 
    
    string [] postedNaturalEventIds; 
    string [] inListenerNotificationNeIds; 
    string [] historicalNaturalEventIds; 
    
    mapping(string=>uint256) inListenerNotificationPostingCounts; 
    mapping(string=>bool) inListenerNotificationKnownCategories; 
    string [] inListenerNotificationCategories; 
    
    IBSODispatch dispatch;

    constructor(address _administrator, 
                address _ibsoDispatch) Administered(_administrator){
        dispatch = IBSODispatch(_ibsoDispatch);
    }
    
    function postNaturalEventDirect(string memory _id, 
        string memory _title,
        string memory _description, 
        uint256 _timestamp,
        bool _closed, 
        string [] memory _categories, string [] memory _geometries, string [] memory _sources ) external returns (string memory _message) {
        administratorOnly(); 
        NaturalEvent memory ne = NaturalEvent({
                                                id : _id, 
                                                title : _title, 
                                                description : _description, 
                                                timestamp : _timestamp, 
                                                closed : _closed, 
                                                categories : _categories, 
                                                geometries : _geometries,
                                                sources : _sources
                                                });   
        string memory message = dispatch.postEvent(_id, _title, _description, _timestamp, _closed, _categories, _geometries, _sources);
        naturalEventPostingMessageByNaturalEventId[_id] = message;
        naturalEventByNaturalEventId[_id] = ne;
        postedNaturalEventIds.push(_id);
        return message; 
    }
    
    function loadListenersToNotify() external returns (bool _loaded){
        administratorOnly(); 
       for(uint x = 0; x < postedNaturalEventIds.length; x++) {
           
            string memory postedNaturalEventId = postedNaturalEventIds[x];
          
            NaturalEvent storage ne = naturalEventByNaturalEventId[postedNaturalEventId];
            

            string [] memory neCategories = ne.categories; 
            
            for(uint y = 0; y <  neCategories.length; y++) {
                
                string memory l_category =  neCategories[y];
                
                if(!inListenerNotificationKnownCategories[l_category]) {
                   
                    inListenerNotificationCategories.push(l_category);
                    inListenerNotificationKnownCategories[l_category] = true; 
                }
                
                address [] memory notificationList = dispatch.getListenersToNotifyForCategory(l_category);
                
                inListenerNotificationPostingCounts[l_category] += notificationList.length; 
                
                addressToNotifyForCategoryByNaturalEventId[postedNaturalEventId][l_category] = notificationList; 
                
            }
            
            inListenerNotificationNeIds.push(postedNaturalEventId);
        }
       
        for(uint z =0; z< postedNaturalEventIds.length; z++){ // clear out
           postedNaturalEventIds.pop();
        }
        
        return true; 
    }
    
    function notifyLastOneNaturalEventListenerInOneCategory(string memory _neId, string memory _category) external returns ( address _listenerNotified, string memory _message, uint256 _remaining) {
        administratorOnly(); 
        address [] storage nList = addressToNotifyForCategoryByNaturalEventId[_neId][_category];
        uint256 remainder = 0; 
        require(nList.length>0, 'no events to notify');
        
        uint256 last =  nList.length-1;
        address _lastAddress = nList[last];
        
        nList.pop(); // remove the address 
        string memory message = dispatch.notifyListener(_neId, _category, _lastAddress);
        
        remainder = last; 
        if(remainder == 0) {
            historicalNaturalEventIds.push(_neId);
            inListenerNotificationNeIds = deleteFromStringArray(inListenerNotificationNeIds, _neId);
        }
        
        return (_lastAddress, message, remainder); 
    }
    
    function deleteFromStringArray(string [] memory _array, string memory _value)internal pure returns (string [] memory _cleansedArray) {
        string[] memory _newArray = new string[](_array.length-1);
        bool deleted = false; 
        for(uint x=0; x < _array.length; x++){
            uint index = x; 
            if(deleted) {
                index = x-1; 
            }
            if(!isEqual(_array[x], _value)) {
                _newArray[index] = _array[x];
            }
            else {
                deleted = true;
            }
        }
        return _newArray;
    }
    
    function setBSOAddress(address _newBSOAddress) external returns (bool _set){
        administratorOnly(); 
        dispatch = IBSODispatch(_newBSOAddress);
        return true; 
    }
    
    function getBSOAddress() view external   returns (address _bsoAddress) {
        return address(dispatch);
    }
    
    function getListenerNotificationCategoryCounts()  external view returns ( string [] memory _categories, uint256 [] memory _counts){
         uint256 [] memory counts = new uint256[](inListenerNotificationCategories.length);
         for(uint256 x = 0; x < inListenerNotificationCategories.length; x++){
             counts[x] = inListenerNotificationPostingCounts[inListenerNotificationCategories[x]];
         }
         return (inListenerNotificationCategories, counts );
    }
    
    function getInListenerNotificationEventCount() external view returns (uint256 _count) {
        return inListenerNotificationNeIds.length; 
    }

    function getPostedEventCount() external view returns (uint256 _postedEventCount) {
        return postedNaturalEventIds.length; 
    }
    
    function getHistoricalNaturalEventCount() external view returns (uint256 _count) {
        return historicalNaturalEventIds.length; 
    }
    
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
       return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    } 
}