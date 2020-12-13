// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <=0.8.0; 
pragma experimental ABIEncoderV2;

import "../rolemanager/Administered.sol";
import "../rolemanager/RoleManager.sol";
import "../pricingmatrix/IPricingMatrix.sol";
import "../bank/IBank.sol";
import "./ITellorManager.sol";
import "./IBSO.sol";
import "./IBSODispatch.sol";
import "./IBSOEventListener.sol";
import "./BSOObjects.sol";

contract BSO is Administered, IBSO, IBSODispatch { 
    
    event logEvent(string _name, string _message);
    
    IPricingMatrix pricingMatrix;
    IRoleManager roleManager; 
    IBank bank; 
    ITellorManager tellor; 
    
    address [] notificationSenderAddresses;
    uint256 [] notificationTimes; 
    address [] notificationReceiverAdresses;
    
    string version; 
    
    uint256 lastUpdated; 
    
    address[] naturalEventListenerAddresses; 
    
    NaturalEvent[] allEvents; 
    mapping(string=>NaturalEvent) naturalEventById; 
    mapping(string=>NaturalEvent[]) naturalEventsByCategory;

    mapping(address=>string) naturalEventListenerIdByListenerAddress; 
    mapping(string=>address) naturalEventListenerAddressByListenerId; 
    
    mapping(address=>address) naturalEventListenerOwnerByListenerAddress; 
    mapping(string=>address) naturalEventListenerOwnerByListenerId; 
    
    mapping(address=>uint256) naturalEventListenerBalanceByListenerAddress; 
    mapping(string=>bool) autoRechargeStatusByListenerId;
    
    mapping(address=>string[]) categoriesByListenerAddress;
    mapping(string=>address[]) naturalEventListenerAddressesByCategory; 
    
    constructor ( string memory _version,  address _administrator, 
                  address _tellorManager, 
                  address _roleManager, 
                  address _pricingMatrixAddress, 
                  address _bankAddress) Administered(_administrator) {
        version = _version;            
        pricingMatrix = IPricingMatrix(_pricingMatrixAddress);
        roleManager = IRoleManager(_roleManager);
        bank = IBank(_bankAddress);
        tellor = ITellorManager(_tellorManager);
    }
    
    function getVersion() override external view returns (string memory _version) {
        return version; 
    }
    
    function getListeningCategories() override external view returns (string [] memory _categories) {
        return pricingMatrix.getAllListeningCategories(); 
    }
    
    function getLastUpdated() override  external view returns (uint256 _lastUpdated) {
        return lastUpdated; 
    }


    function getAvailableEvents() override  view external returns (string [] memory _eventIds, string [] memory _eventTitles, uint256 [] memory _latestEventTimes){
        string [] memory eventIds = new string[](allEvents.length);
        string [] memory eventTitles = new string[](allEvents.length);
        uint256 [] memory latestEventTimes = new uint256[](allEvents.length);
        for(uint x = 0; x < allEvents.length; x++) {
            NaturalEvent memory ne = allEvents[x];
            eventIds[x] = ne.id; 
            eventTitles[x] = ne.title; 
            latestEventTimes[x] = ne.timestamp; 
        }
        return (eventIds, eventTitles, latestEventTimes);
    }

    function getAssetPairCodes() override external returns (string [] memory _allowedAssetPairCodes) {
       return tellor.getAllAssetCodes(); 
    }

    function getAssetPriceOnEventFee() override external view returns (uint256 _fee){
        return pricingMatrix.getEventAssetPriceRequestFee(); 
    }
    
    function getAssetPriceOnEvent(string memory _eventId, string memory _assetPairCode, uint256 _fee) payable override  external returns (uint256 _price){ // returns the price of an asset pair at the time of an event
        require(msg.value == _fee, 'bso:gape:00 - fee sent does not match fee declared. Please recalculate and send again. ');  // check the correct fee has been sent

        NaturalEvent memory l_ne = naturalEventById[_eventId]; // find the right event
        
        uint256 l_eventPrice = pricingMatrix.getEventAssetPriceRequestFee(); // find the price for the event's category
        
        require(l_eventPrice <= _fee, 'bso:gape:01 - insufficient fee sent. Please recalculate and send again. '); // make sure that the fee paid is the amount required or more
        
        uint256 l_eventTimestamp = l_ne.timestamp; // get the timestamp
        
        uint256 l_assetPairPrice = retrieveData(_assetPairCode, l_eventTimestamp);
        
        bank.deposit{value : _fee}(_fee, msg.sender, address(this), 'getAssetPriceOnEvent', block.timestamp);
        
        return  (l_assetPairPrice); // retrieve the price of the asset pair 
    }

    function getNaturalEventListenerRegistrationFee() override external view returns (uint256 _fee) {
        return pricingMatrix.getBusinessFee('naturalEventListenerRegistrationFee');
    }

    function getCategoryListeningFees() override  external view returns (string[] memory _categories, uint256[] memory _fees){
        return pricingMatrix.getAllListeningCategoryFees(); // get the fees required to register a listener
    }
    
    function registerNaturalEventListener(address payable _address, uint256 _registrationFee, uint256 _eventListeningCredit) payable override  external returns (string memory _message){
        require(msg.value == (_registrationFee+_eventListeningCredit),'bso:rnel:00 -  total monetary value sent does not equal total value declared. Please recalculate and send again. '); 
        require(msg.value > _registrationFee, 'bso:rnel:01 - registration fee sent does not match registration fee declared. Please recalculate and send again.'); // make sure the fee agrees with what's sent
        
        uint256 requiredRegistrationFee = pricingMatrix.getBusinessFee('naturalEventListenerRegistrationFee');
        require(_registrationFee >= requiredRegistrationFee, 'bso:rnel03 - insufficent registiration fee. Please check the fee and send again');
        
        
        
        IBSOEventListener listener = IBSOEventListener(_address);
        
        string memory _id = listener.getListenerId(); 
        
        naturalEventListenerOwnerByListenerAddress[_address] = listener.getOwnerAddress();
        
        bool autoRechargeEnabled = listener.isAutoRechargeEnabled(); 
        autoRechargeStatusByListenerId[_id] = autoRechargeEnabled;
        
        string[] memory l_categories = listener.getCategories(); 
        
        uint256 oneTimeNaturalEventAllCategoryListeningPriceTotal = 0; 

        for(uint x = 0; x < l_categories.length; x++){
            oneTimeNaturalEventAllCategoryListeningPriceTotal += pricingMatrix.getListeningCategoryFee(l_categories[x]);
        }
      
        require((_eventListeningCredit > oneTimeNaturalEventAllCategoryListeningPriceTotal), 'bso:rnel:02 - natural event category listening credit insufficient to listen to all declared categories at least once. Please recalculate and send again.'); 
        naturalEventListenerAddressByListenerId[_id] = _address;
        naturalEventListenerIdByListenerAddress[_address] = _id;
        naturalEventListenerBalanceByListenerAddress[_address] = _eventListeningCredit; 
        
        naturalEventListenerAddresses.push(_address);
        
        for(uint y = 0; y < l_categories.length; y++) {
            string memory category = l_categories[y];
         
            address[] storage catListenerAddresses = naturalEventListenerAddressesByCategory[category];
            catListenerAddresses.push(_address);
        }
        bank.deposit{value : requiredRegistrationFee}(requiredRegistrationFee, msg.sender, address(this), 'registerNaturalEventListener', block.timestamp);
        return 'listener registered'; 
    }
    
    function getListenerBalance(address _listenerAddress) override external view returns (uint256 _balance) { // returns credit remaining for the listener
        return  naturalEventListenerBalanceByListenerAddress[_listenerAddress];
    }
    
    function rechargeEventListener(address _listenerAddress, uint256 _creditAmount) override  external payable returns (string memory _message) {
        onlyListenerOwner(_listenerAddress);
        require(msg.value == _creditAmount);
        uint256 l_currentBalance = naturalEventListenerBalanceByListenerAddress[_listenerAddress];
        uint256 newBalance = l_currentBalance + _creditAmount; 
        naturalEventListenerBalanceByListenerAddress[_listenerAddress] = newBalance; 
        return 'listener credited';
    }
    
    
    function deregisterNaturalEventListener(address payable _address) override external returns(address _ad, uint256 _refund, string memory _message){
        onlyListenerOwner(_address);

        bool deleted = false; 
        uint listenerLength = naturalEventListenerAddresses.length-1; 
        address[] memory l_listenerAddresses = new address[](listenerLength);
        for(uint x=0; x < naturalEventListenerAddresses.length; x++){
            uint index = x; 
            if(deleted) {
                index = x-1; 
            }
            if(naturalEventListenerAddresses[x] != _address) {
                l_listenerAddresses[index] = naturalEventListenerAddresses[x];
            }
            else {
                deleted = true;
            }
        }
        naturalEventListenerAddresses = l_listenerAddresses;
        
        string memory _id = naturalEventListenerIdByListenerAddress[_address];
        delete naturalEventListenerAddressByListenerId[_id]; // remove the listener 
        
        string [] memory l_categories = categoriesByListenerAddress[_address];
        delete categoriesByListenerAddress[_address]; // clear out the mapping 
        
        deleted = false; // reset deleted 
        for(uint y = 0; y < l_categories.length; y++){
            
            string memory l_category = l_categories[y];
            address[] memory catlistenerAddresses = naturalEventListenerAddressesByCategory[l_category];
            address[] memory newCatListenerAddresses = new address[](catlistenerAddresses.length-1);
            
            for(uint z = 0; z < catlistenerAddresses.length; z++) {
                uint index = z; 
                if(deleted) {
                    index = z-1; 
                }
                if(catlistenerAddresses[z] != _address) {
                    newCatListenerAddresses[index]  = catlistenerAddresses[z];
                }
                else {
                    deleted = true; 
                }

            }
           naturalEventListenerAddressesByCategory[l_category] = newCatListenerAddresses; 
        }
        
        uint256 l_listenerBalance = naturalEventListenerBalanceByListenerAddress[_address];  // find the remaining balance
        delete naturalEventListenerBalanceByListenerAddress[_address];
        IBSOEventListener l_listener = IBSOEventListener(_address);
        l_listener.acceptRefund{value : l_listenerBalance}(l_listenerBalance); // refund the remaining balance
        return (_address, l_listenerBalance, 'listener deregistered'); 
    }
    
    // this will serve to the listeners that need to be notified for a given category
    function getListenersToNotifyForCategory(string memory _category) override external returns (address [] memory _listenerAddresses) {
        roleManager.roleOnly('NODE_OPERATOR', msg.sender); 
        address [] memory categoryListenerAddresses = naturalEventListenerAddressesByCategory[_category];
       
        uint256 validListenerCount = 0; 
       
        address[] memory validListeners = new address[](categoryListenerAddresses.length);
       
       
        for(uint x = 0; x < categoryListenerAddresses.length; x++) {
            address listenerAddress = categoryListenerAddresses[x];
            if(hasFee(_category, listenerAddress)) {
                emit  logEvent('step', 'hasFee');
                validListeners[validListenerCount] = listenerAddress; 
                validListenerCount++;
            }           
            
        }
        
        address[] memory validAddresses; 
        
        if(validListenerCount == validListeners.length) {
            // all valid
            validAddresses = validListeners; 
        }
        else {
            // truncate
                validAddresses = new address[](validListenerCount);
            for(uint y = 0; y < validListenerCount; y++) {
                validAddresses[y] = address(validListeners[y]);
            }
        }
        
        return validAddresses;
    }
    
    function notifyListener(string memory _naturalEventId, string memory _category, address _listenerAddress) override external returns (string memory _message) {
        roleManager.roleOnly('NODE_OPERATOR', msg.sender);                            
        
        notificationSenderAddresses.push(msg.sender);
        notificationReceiverAdresses.push(_listenerAddress);
        notificationTimes.push(block.timestamp);
        
        NaturalEvent memory ne = naturalEventById[_naturalEventId];
        string memory _id = ne.id; 
        string memory _title = ne.title;
        string memory _description = ne.description; 
        uint256 _timestamp = ne.timestamp;
        bool _closed = ne.closed; 
        string [] memory _categories = ne.categories;
        string [] memory _geometries = ne.geometries;
        string [] memory _sources = ne.sources;
      
        IBSOEventListener listener = IBSOEventListener(_listenerAddress);
        if (deductFee(_category, listener)) {
            string memory assetCode = listener.getAssetCode(); 
            uint256 _assetPrice = tellor.getPrice(assetCode, block.timestamp); 
            string memory _c = _category; // stack issue
            listener.onEvent(_id, _title, _description, _timestamp, _closed, _categories, _geometries, _sources, _assetPrice, _c);
            return 'listener notified.';    
        }
        
        
        return 'listener NOT notified.';
    }
    
    function postEvent(string memory _id, 
                        string memory _title,
                        string memory _description, 
                        uint256 _timestamp,
                        bool _closed, 
                        string [] memory _categories, 
                        string [] memory _geometries,
                        string [] memory _sources) override external returns (string memory _message) {
        roleManager.roleOnly('NODE_OPERATOR', msg.sender);                             
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
        allEvents.push(ne);
        naturalEventById[ne.id] = ne; 
            
        string[] memory l_categories = ne.categories;
        for(uint y =0; y< l_categories.length; y++){
            string memory l_category = l_categories[y];
            require(isKnownCategory(l_category),'bso:pe:00 - unknown category presented. Please check your categories or request new category and resubmit');
            NaturalEvent[] storage nes = naturalEventsByCategory[l_category];
            nes.push(ne); 
        }
        
        lastUpdated = block.timestamp; 
        return 'event posting successful';
    }
 
    function getCategoryListenerCounts() external view returns (string [] memory _categories, uint256 [] memory _counts){
        administratorOnly();
        string [] memory categories = pricingMatrix.getAllListeningCategories();
        uint256 [] memory counts = new uint256[](categories.length);
        for(uint x =0; x < categories.length; x++) {
            string memory category = categories[x];
            address[] storage listeners = naturalEventListenerAddressesByCategory[category];
            counts[x] = listeners.length; 
        }
        return (categories, counts);
    }
 
 
    function getNotificationCalls() external view returns ( address [] memory senders, uint256 [] memory times, address [] memory recievers) {
        administratorOnly();
        return(notificationSenderAddresses, notificationTimes, notificationReceiverAdresses);
    }
 
 
    function getPublishedEventCount() external view returns (uint256 _count) {
        administratorOnly();
        return allEvents.length; 
    }
    
    function getRegisteredListenerCount() external view returns (uint256 _listenerCount) {
        administratorOnly();
        return naturalEventListenerAddresses.length; 
    }
     
    function changeConfiguration(string memory _option, address _address) external returns (string memory _message) {
        administratorOnly(); 
        if(isEqual(_option, 'BANK')) {
            bank = IBank(_address); 
            return 'bank set';
        } 
        if(isEqual(_option, 'PRICING_MATRIX')) {
            pricingMatrix = IPricingMatrix(_address);
            return 'pricing matrix set';
        } 
        if(isEqual(_option, 'ROLE_MANAGER')) {
            roleManager = IRoleManager(_address);
            return 'role manager set';
        } 
        if(isEqual(_option, 'TELLOR_MANAGER')) {
            tellor = ITellorManager(_address);
        }
        return 'no values altered';
    }
 
 
    function retrieveData(string memory _assetPairCode, uint256 _eventTimestamp) internal returns (uint256 _price) { 
        uint256 price = tellor.getPrice(_assetPairCode, _eventTimestamp);
        return price;
    }
    
    function isKnownCategory(string memory _category) internal view returns (bool _isKnown) {
        string [] memory categories = pricingMatrix.getAllListeningCategories();
        for(uint x =0; x < categories.length; x++) {
            if(isEqual(_category, categories[x])) {
                return true; 
            }
        }
        return false; 
    }
    
    function hasFee(string memory _category, address _listenerAddress) internal  returns (bool _success) {
        uint256 listenerBalance = naturalEventListenerBalanceByListenerAddress[_listenerAddress];
        
        uint256 fee = pricingMatrix.getListeningCategoryFee(_category);
    
        if(listenerBalance > fee) { 
             emit logEvent('step', 'has balance');
             return true; 
        }
        else { 
            // check whether auto recharge is on
            emit logEvent('step', 'checking autorecharge');
            string memory listenerId = naturalEventListenerIdByListenerAddress[_listenerAddress];
            if(autoRechargeStatusByListenerId[listenerId]) { 
               return true; 
            }
        }
        emit logEvent('step', 'no balance');
        
        return true; 
    }
    
    function deductFee(string memory _category, IBSOEventListener _listener) internal returns (bool _success) {
        address listenerAddress = address(_listener);
        
        uint256 listenerBalance = naturalEventListenerBalanceByListenerAddress[listenerAddress];
        uint256 fee = pricingMatrix.getListeningCategoryFee(_category);
        if(listenerBalance > fee) { 
            uint256 newBalance = listenerBalance - fee; 
            naturalEventListenerBalanceByListenerAddress[listenerAddress] = newBalance; 
            bank.deposit{value : fee}(fee, msg.sender, address(this), 'deductFee', block.timestamp);
            return true; 
        }
        else { 
            // check whether auto recharge is on and try to rebill 
            string memory listenerId = naturalEventListenerIdByListenerAddress[listenerAddress];
            if(autoRechargeStatusByListenerId[listenerId]) { 
                require(_listener.rechargeListener(), 'bso:df:00 - failed to recharge event listener.');
                listenerBalance = naturalEventListenerBalanceByListenerAddress[listenerAddress]; // get the updated balance
                if(listenerBalance > fee) { 
                    uint256 newBalance = listenerBalance - fee; 
                    naturalEventListenerBalanceByListenerAddress[listenerAddress] = newBalance; 
                    bank.deposit{value : fee}(fee, msg.sender, address(this), 'deductFee', block.timestamp);
                    return true; 
                }
            }
        } 
        return false; 
    }
    
    function onlyListenerOwner(address _listenerAddress)internal view returns( string memory _message) {
        address owner = naturalEventListenerOwnerByListenerAddress[_listenerAddress];
        require(msg.sender == owner || msg.sender == administrator, 'bso:olo:00 - invalid permissions presented');
        return 'owner ok';
    }
    
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
       return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    } 
}