// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @author Taurai Ushewokunze 
 */
 
    struct NaturalEvent {
        string id; 
        string title; 
        string description; 
        uint256 timestamp; 
        bool closed; 
        string [] categories;
        string [] sources; 
        string [] geometries; 

    }
    
    struct Geometry {
        string geotype;
        uint256 date; 
        string longitude; 
        string latitude; 
    }
    
    struct EventSource { 
        string id; 
        string url; 
    }
    
    struct NaturalEventLite {
        string id; 
        string title; 
        uint256 timestamp; 
    }
    
    struct BSONENotification { 
        string category; 
        address bsoListenerAddress; 
        bool feeDeducted; 
        uint256 assetPairPrice; 
    }

contract BSOObjects { 
    

}