// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @title the Block Sat Oracle
 * @author Taurai Ushewokunze
 * @dev This is the interface that is publicly exposes the oracle. It supports acquisition of  'crypto asset prices' for published 'Natural Events' and 
 * it provides an ability to listen for 'Natural Events' and acquire 'crypto asset prices' by registering an implementation of the 'IBSOEventListener.sol' interface. 
 * Natural Event Data is provided by 'NASA'
 * Pricing is provided by 'Tellor'
 */ 
interface IBSO {
    
    /**
     * @dev this operation provides the version of the implementation of 'IBSO.sol'
     * @return _version of implementation
     */
    function getVersion() external view returns (string memory _version);
    
    /**
     * @dev this operation provides when the data the Block Sat was last updated by a Node 
     * @return _lastUpdated the epoch time since the last oracle update
     */
    function getLastUpdated() external view returns (uint256 _lastUpdated); 
    
    /**
     * @dev this operation returns the 'listening categories' that are available on Block Sat
     * @return _categories available from Block Sat
     */ 
    function getListeningCategories() external view returns (string [] memory _categories);
    
    /**
     * @dev this operation returns the 'fee' that needs to be sent for an adhoc asset price request during the time of an event. 
     * @return _fee that needs to be sent by the sender
     */
    function getAssetPriceOnEventFee() view external returns (uint256 _fee);
    
    /**
     * @dev this operation returns the 'crypto asset pair codes' that are allowed for use across Block Sat 
     * @return _allowedAssetPairCodes Tellor derived Crypto Asset codes
     */ 
    function getAssetPairCodes() external returns (string[] memory _allowedAssetPairCodes);
    
    /**
     * @dev this operation returns all Natural Events for which 'crypto asset prices' can be requested adhoc from Block Sat.
     * @return _eventIds for the Natural Events 
     * @return _eventTitles published titles for the Natural Events 
     * @return _latestEventTimes latest time at which the event was known to have occured e.g. when tracking storms
     */
    function getAvailableEvents() external returns (string [] memory _eventIds, string [] memory _eventTitles, uint256 [] memory _latestEventTimes);
    
    /**
     * @dev this operation allows for an adhoc request to be made for a 'crypto asset price' at the time of a particular 'Natural Event'. 
     * The price returned is the price at the point of the latest reported time of the Natural Event. 
     * @param _eventId Natural Event Id available from 'getAvailableEvents'
     * @param _assetPairCode 'crypto asset code' allowed for this service available from 'getAssetPairCodes'
     * @param _fee being sent to pay for this request 
     * @return _price 'crypto asset price' at the latest time of the event
     */
    function getAssetPriceOnEvent(string memory _eventId, string memory _assetPairCode, uint256 _fee) payable external returns (uint256 _price);  // returns the latest price for the given asset at the time the given event occured
   
    /**
     * @dev this operation provides the a listing 'fees' that will be charged when a listener implementing the 'IBSOEventListener.sol' interface is notified of an event.
     * @return _categories listening categories that are available 
     * @return _fees listening category 'fees' in 'wei'
     */
    function getCategoryListeningFees() external view returns (string[] memory _categories, uint256[] memory _fees);  // returns the fees for registering a natural event listener for a given event category

    /**
     * @dev this operation provides a listing of the 'fee' that will be charged when a listener implementing the 'IBSOEventListener.sol' interface is registered with Block Sat
     * @return _fee that will be charged in 'wei'
     */ 
    function getNaturalEventListenerRegistrationFee() external view returns (uint256 _fee);

    /**
     * @dev this operation provides the remaining 'listening credit' balance for the given listener address. This operation is restricted to the 'owner' of the 'listener' at the given address.
     * @return _balance of remaining 'listening credit'
     */
    function getListenerBalance(address _listenerAddress) external returns (uint256 _balance); // returns the credit balance for a given listener can only be called by the listener owner
    
    /**
     * @dev this operation registers the implmentation of 'IBSOEventListener.sol' resident at the given address to listen for Natural Events and to acquire specific 'crypto asset' prices  
     * @param _address of the implementation of IBSOEventListener.sol 
     * @param _fee 'listener' registeration fee available from 'getNaturalEventListenerRegistrationFee'
     * @param _eventListeningCredit 'credit' to pay for event notifications as they occur
     * @return _message with status of registeration
     */
    function registerNaturalEventListener(address payable _address, uint256 _fee, uint256 _eventListeningCredit) payable external  returns (string memory _message); // registeres a natural event listener resident at the given address (must implement IBSOEventListener)

    /**
     * @dev this operation de-registers the implementation of 'IBSOEventListener.sol' resident at the given address. This operation is restricted to the 'owner' of the 'listener' at the given address. 
     * This operation will refund any remaining balance to back to  the 'listener' address via the 'acceptRefund' function in 'IBSOEventListener.sol'
     * @param _listenerAddress to be de-registered 
     * @return _address address of the listener
     * @return _refund amount sent 
     * @return _message status of de-registration 
     */
    function deregisterNaturalEventListener(address payable _listenerAddress) external returns(address _address, uint256 _refund, string memory _message); // deregisters a natural event listnener resident at the given address 
    
    /**
     * @dev this operation will recharge the 'listening credit' balance for the 'IBSOEventListener.sol' implmentation listed in Block Sat at the given address. 
     * @param _listenerAddress to be recharged 
     * @param _creditAmount to be applied 
     * @return _message with status of the recharge
     */
    function rechargeEventListener(address _listenerAddress, uint256 _creditAmount) external payable returns (string memory _message); // adds credit to the for the listener to listen to events can only be called by the listener owner
}