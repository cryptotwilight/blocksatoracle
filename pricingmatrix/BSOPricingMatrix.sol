// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

import "../rolemanager/Administered.sol";
/**
 * Block Sat Oracle Pricing Matrix, controls the prices for the oracle. 
 * 
 * 
 * 
 * 
 */

contract BSOPricingMatrix is Administered  {
    
    
    mapping(string=>uint256) categoryPrices; 
    
    string [] categories;
    uint256 [] prices; 
    
    uint256 lastUpdated; 
    
    constructor(address _administrator) Administered(_administrator) {
    }

    function getLastUpdated() external view returns (uint256 _timeStamp) {
        return lastUpdated; 
    }
    
    function getEventAssetPricingFee() external view returns (uint256 _price) {
        
    }
    
    function getCategoryListeningPrice(string memory _category) external view returns (uint256 _price) {
        return categoryPrices[_category];
    }
    
    function getAllCategoryListeningPrices()  external view returns (string[] memory _categories, uint256[] memory _prices)  {
        return (categories, prices);
    }
    
    function setCategoryListeningPrices(string[] memory _categories, uint256[] memory _prices) external returns (uint256 _updateCount) { // this operation overwrites ALL previous values
        administratorOnly(); 
        categories = _categories;
        prices = _prices; 
        uint256 count = 0; 
        for(uint x =0; x < _categories.length; x++){
            count++;
            categoryPrices[_categories[x]] = _prices[x];
        }
        lastUpdated = block.timestamp; 
        return count; 
    }
    
    
}