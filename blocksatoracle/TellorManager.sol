// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;

import "./ITellorManager.sol";
import "../rolemanager/Administered.sol";
import "https://github.com/tellor-io/usingtellor/blob/master/contracts/UsingTellor.sol";
/**
 * @author Taurai Ushewokunze
 */
contract TellorManager is Administered, UsingTellor, ITellorManager {
    
    uint256 priceRequestCount; 
    string[] ids ; 
    uint256 lastRequestedPrice; 
    uint256 lastRequestId; 
    
    
    constructor(address _administrator, address payable _tellorAddress) Administered(_administrator) UsingTellor(_tellorAddress) {
        initializeIds();
    }
    
    function getPrice(string memory _assetPairCode, uint256 _timestamp) override external returns (uint256 _assetPairPrice) {
        uint256 requestId = convertToId(_assetPairCode);
        lastRequestId = requestId;
        uint256 _price = 10000+requestId; //retrieveData(requestId, _timestamp); // needs to be repared before deployment 
        lastRequestedPrice = _price; 
        priceRequestCount++;
        return _price; 
    }
    
    function getAllAssetCodes() external view returns (string [] memory _assetPairCodes) {
        return ids; 
    }
    
    function getLastRequestedPrice() external view returns (uint256 _price) {
        return lastRequestedPrice; 
    }
    
    
    function getLastRequestedId() external view returns (uint256 _id) {
        return lastRequestId;
    }
    
    
    function getPriceRequestCount() external view returns (uint256 _count){
        return priceRequestCount; 
    }
    
    function convertToId(string memory _assetPairCode) internal view returns (uint256 _requestId) {
        for(uint x = 0; x < ids.length; x++) {
            if(isEqual(ids[x],_assetPairCode)) {
                return x+1; 
            }
        }
        return 0;
    }
    
    function isEqual(string memory a, string memory b ) internal pure returns (bool _isEqual) {
       return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    } 
    
    function initializeIds() internal returns (bool _done) {
        ids.push("ETH/USD");
        ids.push("BTC/USD");
        ids.push("BNB/USD");
        ids.push("BTC/USD 24 Hour TWAP");
        ids.push("ETH/BTC");
        ids.push("BNB/BTC");
        ids.push("BNB/ETH");
        ids.push("ETH/USD 24 Hour TWAP");
        ids.push("ETH/USD EOD Median");
        ids.push("AMPL/USD Custom");
        ids.push("ZEC/ETH");
        ids.push("TRX/ETH");
        ids.push("XRP/USD");
        ids.push("XMR/ETH");
        ids.push("ATOM/USD");
        ids.push("LTC/USD");
        ids.push("WAVES/BTC");
        ids.push("REP/BTC");
        ids.push("TUSD/ETH");
        ids.push("EOS/USD");
        ids.push("IOTA/USD");        
        ids.push("ETC/USD");
        ids.push("ETH/PAX");
        ids.push("ETH/BTC 24 Hour TWAP");
        ids.push("USDC/USDT");
        ids.push("XTZ/USD");
        ids.push("LINK/USD");
        ids.push("ZRX/BNB");
        ids.push("ZEC/USD");
        ids.push("XAU/USD");
        ids.push("MATIC/USD");
        ids.push("BAT/USD");
        ids.push("ALGO/USD");
        ids.push("ZRX/USD");
        ids.push("COS/USD");
        ids.push("BCH/USD");
        ids.push("REP/USD");
        ids.push("GNO/USD");
        ids.push("DAI/USD");        
        ids.push("STEEM/BTC");
        ids.push("USPCE");
        ids.push("BTC/USD EOD Median");
        ids.push("TRB/ETH");
        ids.push("BTC/USD 1 Hour TWAP");
        ids.push("TRB/USD EOD Median");      
        ids.push("ETH/USD 1 Hour TWAP");
        ids.push("BSV/USD");
        ids.push("MAKER/USD");
        ids.push("BCH/USD 24 Hour TWAP");
        ids.push("TRB/USD");
        ids.push("XMR/USD");
        ids.push("XFT/USD");
        ids.push("BTCDominance");
        return true; 
    }
}