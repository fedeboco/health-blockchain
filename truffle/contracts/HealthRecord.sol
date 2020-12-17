// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract HealthRecord {
  address private patient;
  string private recordHash;
  bool private seen;

  constructor() public {}

  function uploadRecord(  string memory inputHash, 
                          address inputPatient) 
                          public returns(bool) {
    recordHash = inputHash;
    patient = inputPatient;
    seen = false;
    return true;
  }

  function getRecordHash() public view returns (string memory) {
    require(msg.sender == patient, "Invalid address.");
    return recordHash;
  }
}