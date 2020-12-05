// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

interface IPricingMatrix { 
    
    function getLastUpdated() external view returns (uint256 _timeStamp);
    
    function getEventAssetPriceRequestFee() external view returns (uint256 _price);
    
    function getCategoryListeningPrice(string memory _category) external view returns (uint256 _price);
    
    function getAllCategoryListeningPrices()  external view returns (string[] memory _categories, uint256[] memory _prices);
    
}