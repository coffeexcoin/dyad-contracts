// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import "forge-std/Test.sol";

import {DeployV2, Contracts} from "../../script/deploy/Deploy.V2.s.sol";

contract V2Test is Test {

  Contracts contracts;

  function setUp() public {
    contracts = new DeployV2().run();
  }

  function testDenominator() public {
    uint denominator = contracts.kerosineDenominator.denominator();
    console.log(denominator);
  }
}
