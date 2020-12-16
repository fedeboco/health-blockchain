// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

contract HelloWorld {
  constructor() public {
  }

  function hi() public pure returns (string memory) {
    return ("Hola");
  }
}
