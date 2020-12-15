// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @title Pricing Matrix interface for Block Sat 
 * @author Taurai Ushewokunze
 * @dev The Pricing Matrix is used to set all prices/fees used in Block Sat. 
 */ 
interface IPricingMatrix { 
    
    /**
     * @dev This operation returns when the Pricing Matrix was last updated 
     * @return _timeStamp time at which the update occured 
     */ 
    function getLastUpdated() external view returns (uint256 _timeStamp);
    
    /**
     * @dev This operation returns all available 'listening categories' configured in this 'Pricing Matrix' 
     * @return _listeningCategories configured 'listening categories'
     */
    function getAllListeningCategories() external view returns (string [] memory _listeningCategories);
    
    /**
     * @dev This operation returns the fee payable when making a asset price request for a specific event
     * @return _fee fee that is payable on making the asset price request for the event see 'IBSO.getAssetPriceOnEvent'
     */
    function getEventAssetPriceRequestFee() external view returns (uint256 _fee);
    
    /**
     * @dev This operation returns the 'listening fee' required to listen to a particular 'listening category'
     * @param _category listening category of interest 
     * @return _fee charged to the listener during the notification process see 'IBSOEventListener.onEvent'
     */
    function getListeningCategoryFee(string memory _category) external view returns (uint256 _fee);
    
    /**
     * @dev This operation returns all the available 'listening categories' matched to their associated 'listening fees'
     * @return _categories all configured 'listening categories'
     * @return _fees all 'listening category' associated fees 
     */ 
    function getAllListeningCategoryFees()  external view returns (string[] memory _categories, uint256[] memory _fees);
    
    /**
     * @dev This operation returns the value of the 'business fee' utilised internal to Block Sat 
     * @param _feeName of the 'business fee' e.g. see 'IBSO.getNaturalEventListenerRegistrationFee'
     * @return _fee value of the 'business fee'
     */
    function getBusinessFee(string memory _feeName) external view returns (uint256 _fee);
    

}