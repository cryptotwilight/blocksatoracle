// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <=0.8.0; 
pragma experimental ABIEncoderV2;

import "../blocksatoracle/BSOObjects.sol";
import "../blocksatoracle/IBSOEventListener.sol";
import "../rolemanager/Administered.sol"; 
/**
 * @title Mock Block Sat Natural Event Listener
 * @author Taurai Ushewokunze 
 * @dev This code mimics the behaviour of a natural event listener that listens for particular Natural Events like storms etc posted to Block Sat.
 */ 
contract MockBSOEventListener is IBSOEventListener, Administered { 
   
    event logMBSOELEvent(string _name, string _note);
   
    address ownerAddress; 
    string[] listenerCategories;
    
    mapping(string=>uint256) assetPriceByNaturalEventId; 
    mapping(string=>NaturalEvent[]) eventsByCategory; 
    
    mapping(string=>NaturalEvent) naturalEventByNaturalEventId; 
    NaturalEvent[] eventList; 
    
    mapping(string=>NaturalEvent[]) notificationsForCategoryByCategory; 
    
    constructor(address _administrator) Administered(_administrator) {
        ownerAddress = msg.sender; 
               
        listenerCategories.push("Wildfires");
        listenerCategories.push("Volcanoes");
    }
    
    function getHeardEventCount() external view returns (uint256 _count) {
        return eventList.length; 
    }
    
    function getListenerId() override external view returns(string memory _id) {
        return 'test_event_listener';
    }
    
    function getAssetCode() override external returns (string memory _assetCode){
        emit logMBSOELEvent("step", "asset code requested" );
        return "BTC/USD";
    }
    
    function getCategories() override external view returns (string[] memory _categoriesOfInterest) {
        return listenerCategories;
    }
    
    function isAutoRechargeEnabled() override external returns (bool _enabled) {
        emit logMBSOELEvent("step", "isAuto Recharge Enabled Requested" );
        return false; 
    }
    
    function rechargeListener() override external returns (bool _isRecharged) {
        return false;  
    }
    
    function getOwnerAddress() override external returns (address _ownerAddress) {
        return ownerAddress; 
    }
    
    function onEvent( string memory _id, 
                      string memory _title,
                      string memory _description, 
                      uint256 _timestamp,
                      bool _closed, 
                      string [] memory _categories, 
                      string [] memory _geometries, 
                      string [] memory _sources, 
                      uint256 _assetPrice, string memory notificationForCategory) override external returns (bool _success){
       
        NaturalEvent memory _event = NaturalEvent({
                                                id : _id, 
                                                title : _title, 
                                                description : _description, 
                                                timestamp : _timestamp, 
                                                closed : _closed, 
                                                categories : _categories, 
                                                geometries : _geometries,
                                                sources : _sources
                                                }); 
        
        notificationsForCategoryByCategory[notificationForCategory].push(_event); // account for each notification because you may get a duplicate as you'll be notified for each category. 
        emit logMBSOELEvent("step", "heard natural event created");
        naturalEventByNaturalEventId[_id] = _event; 
        eventList.push(_event);
       
        assetPriceByNaturalEventId[_id] = _assetPrice; 
        
        for(uint x = 0; x < listenerCategories.length; x++) {
            string memory l_category = listenerCategories[x];
           
            string [] memory eventCategories = _event.categories; 
            for(uint y = 0; y < eventCategories.length; y++) {
                
                string memory e_category = eventCategories[y];
                if(isEqual(l_category, e_category)) { // same category 
                    eventsByCategory[l_category].push(_event);
                }
            }
        }
        emit logMBSOELEvent("step", "event processing completed");

        return true; 
    } 
    
    function acceptRefund(uint256 _refundAmount) override external payable returns (bool _success) {
        require(msg.value == _refundAmount);
        return true; 
    }

    function getEventsByCategory(string memory _category)  external view returns (string[] memory _eventNames, string[] memory _eventIds, uint256[] memory _timestamps, uint256[] memory _assetPrices) {
        NaturalEvent[] memory nes = eventsByCategory[_category];
        
        string [] memory l_names = new string[](nes.length);
        string [] memory l_ids = new string[](nes.length);
        uint256 [] memory l_ts = new uint256[](nes.length);
        uint256 [] memory l_ap = new uint256[](nes.length);
        
        for(uint x = 0; x < nes.length; x++ ){
            NaturalEvent memory ne = nes[x];
            l_names[x] = ne.title;
            l_ids[x] = ne.id;
            l_ts[x] = ne.timestamp; 
            l_ap[x] = assetPriceByNaturalEventId[ne.id];
        }
        
        return (l_names, l_ids, l_ts, l_ap);
    }
    
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
       return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    } 
}