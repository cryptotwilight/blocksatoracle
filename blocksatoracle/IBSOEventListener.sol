// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @title Block Sat Oracle Event Listener. 
 * @author Taurai Ushewokunze 
 * @dev Block Sat Oracle Event Listener interface. This interface is used to listen for Natural Events and request prices real time from Block Sat. 
 * NOTE: Implementers should secure their operation implementations against the Block Sat Oracle address issued by the gateway to prevent rogue actors manipulating their services
 * The Block Sat Oracle team accept no liability for any hacks of implmenter implementations 
 */
interface IBSOEventListener {
    
    /**
     * @dev this operation should return the unique id provided by the implmenter for this 'IBSOEventListener.sol' implementation
     * @return _id unique id for Listener
     */ 
    function getListenerId() external returns(string memory _id);
    
    /** 
     * @dev this operation should return the asset code selected from 'getAssetPairCodes' on 'IBSO.sol'
     * @return _assetCode implementor selected 'crypto asset code'
     */
    function getAssetCode() external returns (string memory _assetCode);
    
    /**
     * @dev this operation should return the Listening Categories selected from 'getListeningCategories' on 'IBSO.sol'
     * @return _categoriesOfInterest to the Implementers
     */ 
    function getCategories() external returns (string[] memory _categoriesOfInterest);
    
    /**
     * @dev this operation should return whether or not automated 'Listening credit' requests are supported by this implementation. If enabled a call will be made to the 'rechardListener()' operation
     * when the balance for this implementation is insufficient to service a relevant Natural Event notification
     * @return _enabled true if automated recharge of listener credit is enabled
     */ 
    function isAutoRechargeEnabled() external returns (bool _enabled);
    
    /** 
     * @dev this operation should recharge the Block Sat 'IBSO.sol', 'listening credit' balance of this implementation 
     * @return _recharged true if the recharge operation has been successful
     */ 
    function rechargeListener() external returns (bool _recharged);
    
    /**
     * @dev this operation should return the 'owner' address of this implementation 
     * @return _ownerAddress of this implementation
     */
    function getOwnerAddress() external returns (address _ownerAddress);
    
    /**
     * @dev this operation should process the event notifications sent by Block Sat 'IBSO.sol' 
     * @param _id for this Natural Event usually EONET
     * @param _title for this Natural Event
     * @param _description of this Natural Event
     * @param _timestamp at which this Natural Event first occured
     * @param _closed true if this Natural Event is over
     * @param _categories to which this natural event applies
     * @param _geometries in which this natural event is occuring
     * @param _sources links to off chain information sources for this Natural Event
     * @param _assetPrice for the asset associated with this listener
     * @param _notificationForCategory for which this 'listener' is being notified and billed
     * @return _success this should return true  
     */
    function onEvent( string memory _id, string memory _title, string memory _description, uint256 _timestamp, 
    bool _closed, string [] memory _categories, string [] memory _geometries, string [] memory _sources,  uint256 _assetPrice,
    string memory _notificationForCategory) external returns (bool _success); 
    
    /**
     * @dev this operation should accept any refunds issued by Block Sat 'IBSO.sol' to this implementation 
     * @param _refundAmount amount that has been refunded to this implementation. 
     */ 
    function acceptRefund(uint256 _refundAmount) external payable returns (bool _success); 
    
}