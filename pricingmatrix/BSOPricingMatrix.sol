// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

import "../rolemanager/Administered.sol";
import "./IPricingMatrix.sol";
/**
 * @author Taurai Ushewokunze 
 */

contract BSOPricingMatrix is Administered, IPricingMatrix  {
    
    
    string [] listeningCategories;
    uint256 [] listeningCategoryFees; 
    mapping(string=>bool) knownCategoryBoolByCategory; 
    mapping(string=>uint256) listeningCategoryFeeByListeningCategory; 
    
    // business fees
    string [] businessFeeNames; 
    mapping(string=>uint256) businessFeeByBusinessFeeName; 
    
    uint256 lastUpdated; 
    
    constructor(address _administrator) Administered(_administrator) {
    }

    function getLastUpdated() override external view returns (uint256 _timeStamp) {
        return lastUpdated; 
    }
    
    function getBusinessFee(string memory _feeName) override external view returns (uint256 _fee){
        return businessFeeByBusinessFeeName[_feeName];
    }
    
    function getEventAssetPriceRequestFee() override external view returns (uint256 _fee) {
        return businessFeeByBusinessFeeName['eventAssetPriceRequestFee']; 
    }
    
    function getAllListeningCategories() override external view returns (string [] memory _listeningCategories) {
        return listeningCategories; 
    }
    
    function getListeningCategoryFee(string memory _category) override external view returns (uint256 _fee) {
        return listeningCategoryFeeByListeningCategory[_category];
    }
    
    function getAllListeningCategoryFees()  override external view returns (string[] memory _categories, uint256[] memory _fees)  {
        return (listeningCategories, listeningCategoryFees);
    }
    
    function getAvailableBusinessFeeNames() external view returns (string [] memory _feeNameList) {
        administratorOnly();
        return businessFeeNames; 
    }
    
    function setFee(string memory _feeName, uint256 _feeFinney)  external returns (bool _set){
        administratorOnly();
        if(!knownFeeName(_feeName)) {
            businessFeeNames.push(_feeName);
        }
        businessFeeByBusinessFeeName[_feeName] = convertToWei(_feeFinney); 
        lastUpdated = block.timestamp; 
        return true; 
    }
    
    function removeBusinessFee(string memory _feeName) external returns (bool _isRemoved) {
        administratorOnly(); 
        require(knownFeeName(_feeName), 'bsopm:rbf:00 - Unknown business fee removal requested');
        deleteFromStringArray(businessFeeNames, _feeName);
        delete businessFeeByBusinessFeeName[_feeName];
        return true; 
    }
    
    function removeCategoryListeningFee(string memory _category) external returns (bool _isRemoved) {
        administratorOnly(); 
        delete listeningCategoryFeeByListeningCategory[_category];
        delete knownCategoryBoolByCategory[_category];
        listeningCategories = deleteFromStringArray(listeningCategories, _category);
        listeningCategoryFees = deleteIndexFromUint256Array(listeningCategoryFees, getIndexFromStringArray(listeningCategories, _category));
        return true; 
    }
    
    function setCategoryListeningFees(string[] memory _categories, uint256[] memory _listeningFees) external returns (uint256 _updateCount) { // this operation overwrites ALL previous values
        administratorOnly(); 
        require(_categories.length == _listeningFees.length, 'pmx:sclp:00 - number of categories does not match number of listening fees declared. Please check and resubmit.');
        uint256 [] memory convertedListeningFees = convertFees(_listeningFees);
        for(uint x = 0; x < _categories.length; x++) {
            string memory category = _categories[x];
            uint256 listeningFee = convertedListeningFees[x];
            listeningCategoryFeeByListeningCategory[category] = listeningFee;
            if(!isKnownCategory(category)) {
                listeningCategories.push(category); 
                listeningCategoryFees.push(listeningFee); 
            }
        }
        lastUpdated = block.timestamp; 
        return (_categories.length); 
    }
    
    function convertFees(uint256[] memory _pricesFinney) internal pure returns (uint256[] memory _convertedPrices) {
        uint256[] memory convertedPrices = new uint256[](_pricesFinney.length);
        for(uint x = 0; x < _pricesFinney.length; x++) {
            convertedPrices[x] = convertToWei(_pricesFinney[x]);
        }
        return convertedPrices; 
    }
    
    function convertToWei(uint256 _value)  internal pure returns (uint256 _converted) {
        return _value * 1e15; 
    }
    
    function isKnownCategory(string memory _category) internal view returns (bool _isKnown) {
        return knownCategoryBoolByCategory[_category];
    }
    
    function knownFeeName(string memory _feeName)  internal view returns (bool _isKnown) {
        for(uint x = 0; x < businessFeeNames.length; x++) {
            if(isEqual(_feeName, businessFeeNames[x])) {
                return true; 
            }
        }
        return false; 
    }
    
    function deleteIndexFromUint256Array(uint256 [] memory _array, uint256 _index) internal pure returns (uint256 [] memory _cleansedArray) {
        uint256 []memory _newArray = new uint256[](_array.length-1);
        uint y = 0; 
        bool deleted = false; 
        for(uint x=0; x < _array.length; x++){
            if(deleted) {
                y = x-1; 
            }
            else { 
                y = x;     
            }
            
            if(x != _index) {
                _newArray[y] = _array[x];
            }
            else {
                deleted = true;
            }
        }
        return _newArray;
    }
    
    function deleteFromUint256Array(uint256 [] memory _array, uint256 _value) internal pure returns (uint256 [] memory _cleansedArray) {
        uint256 [] memory _newArray = new uint256[](_array.length-1);
        bool deleted = false; 
        for(uint x=0; x < _array.length; x++){
            uint index = x; 
            if(deleted) {
                index = x-1; 
            }
            if(_array[x] != _value) {
                _newArray[index] = _array[x];
            }
            else {
                deleted = true;
            }
        }
        return _newArray;
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

    function getIndexFromStringArray(string [] memory _array, string memory _value) internal pure returns (uint _index) {
        for(uint x=0; x < _array.length; x++){
            if((isEqual(_array[x], _value))) {
                return x; 
            }
        }
        return 0; 
    }

    
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
       return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    } 
    
}