// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.4.0 <0.8.0; 
pragma experimental ABIEncoderV2;
/**
 * @title Block Sat Oracle of chain integration interface
 * @author Taurai Ushewokunze
 * @dev this provides the interface into which off chain satellite data should be posted into the Block Sat Oracle. 
 * The order of execution is that a node must first 'postEvent' with all the data, then acquire the 'listeners'  via 'getListenersToNotifyForCategory'
 * then notify each listener in a separate execution thread via 'notifyListener'. 
 * NOTE: listener are an implementation of the 'IBSOEventListener.sol' interface and the 'onEvent' operation that is called executes random code. 
 * 
 */ 
interface IBSODispatch { 
 
 /**
  * @dev this operation allows 'registered' Nodes to post off chain Natural Event Satellite Data to the Block Sat Oracle.
  * @param _id international recognised identifier for the event such as Earth Observatory Natural Event Tracker (EONET) from NASA
  * @param _title describing the event 
  * @param _description of the event 
  * @param _timestamp when the event first occured 
  * @param _closed true if the event is now over
  * @param _categories to which the event applies 
  * @param _geometries a series of coordinates where the event is taking place
  * @param _sources original sources from where the data was first acquired 
  * @return _message with the status of the post 
  */
 function postEvent(string memory _id, string memory _title, string memory _description, uint256 _timestamp, bool _closed, string [] memory _categories, string [] memory _geometries, string [] memory _sources) external returns (string memory _message);
 /**
  * @dev this is the operation allows for the retrieval by 'registered' Nodes the listeners registered for a particular listening category. 
  * @param _category the 'Listening Category' to be notified 
  * @return _listenerAddresses on chain addresses where an implementation of the 'IBSOEventListener.sol' interface resides
  */
 function getListenersToNotifyForCategory(string memory _category)  external returns (address [] memory _listenerAddresses);
 /**
  * @dev this is the operation that allows for the notification of a given 'listener' of the occurance of a Natural Event within a particular category
  * @param _naturalEventId the 'posted' natural event id 
  * @param _category the category of the 'posted' natural event and for which the 'listener' is listening 
  * @return _message with the status of the notification
  */ 
 function notifyListener(string memory _naturalEventId, string memory _category, address _listenerAddress) external returns (string memory _message);

    
}