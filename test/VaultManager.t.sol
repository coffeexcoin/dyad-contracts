// SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "forge-std/console.sol";
import {VaultManagerTestHelper} from "./VaultManagerHelper.t.sol";
import {IVaultManager} from "../src/interfaces/IVaultManager.sol";

contract VaultManagerTest is VaultManagerTestHelper {

  ///////////////////////////
  // add
  function test_add() public {
    uint id = mintDNft();
    vaultManager.add(id, address(vault));
    assertEq(vaultManager.vaults(id, 0), address(vault));
  }

  function test_addTwoVaults() public {
    uint id = mintDNft();
    addVault(id, RANDOM_VAULT_1);
    addVault(id, RANDOM_VAULT_2);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_1), true);
    assertEq(vaultManager.isDNftVault(id, RANDOM_VAULT_2), true);
    assertEq(vaultManager.vaults(id, 0), RANDOM_VAULT_1);
    assertEq(vaultManager.vaults(id, 1), RANDOM_VAULT_2);
    vm.expectRevert();
    vaultManager.vaults(id, 2); // out of bounds
  }

  function testCannot_add_exceptForDNftOwner() public {
    uint id = mintDNft();
    vm.prank(address(1));
    vm.expectRevert(IVaultManager.NotOwner.selector);
    vaultManager.add(id, address(vault));
  }

  function testFail_add_moreThanMaxNumberOfVaults() public {
    uint id = mintDNft();

    for (uint i = 0; i < vaultManager.MAX_VAULTS(); i++) {
      addVault(id, address(uint160(i)));
    }
    // this puts it exactly one over the limit and should fail
    addVault(id, RANDOM_VAULT_1); 
  }

  function testCannot_add_unlicensedVault() public {
    uint id = mintDNft();
    vm.expectRevert(IVaultManager.VaultNotLicensed.selector);
    vaultManager.add(id, RANDOM_VAULT_1);
  }

  function testFail_cannotAddSameVaultTwice() public {
    uint id = mintDNft();
    addVault(id, RANDOM_VAULT_1);
    addVault(id, RANDOM_VAULT_1);
  }

  ///////////////////////////
  // remove
  function test_remove() public {
    uint id = mintDNft();
    vaultManager.add(id, address(vault));
    vaultManager.remove(id, address(vault));
  }

  function testCannot_remove_exceptForDNftOwner() public {
    uint id = mintDNft();
    vaultManager.add(id, address(vault));
    vm.prank(address(1));
    vm.expectRevert(IVaultManager.NotOwner.selector);
    vaultManager.remove(id, address(vault));
  }

  ///////////////////////////
  // deposit
  function test_deposit() public {
    uint id = mintDNft();
    uint AMOUNT = 1e18;
    deposit(id, address(vault), AMOUNT);
    assertEq(vault.id2asset(id), AMOUNT);
  }

  ///////////////////////////
  // withdraw
  function test_withdraw() public {
    uint id = mintDNft();
    deposit(id, address(vault), 1e18);
    vaultManager.withdraw(id, address(vault), 1e18, RECEIVER);
  }

  ///////////////////////////
  // mintDyad
  function test_mintDyad() public {
    uint id = mintDNft();
    deposit(id, address(vault), 1e22);
    vaultManager.mintDyad(id, 1e20, RECEIVER);
  }

  ///////////////////////////
  // burnDyad
  function test_burnDyad() public {
    uint id = mintDNft();
    deposit(id, address(vault), 1e22);
    vaultManager.mintDyad(id, 1e20, address(this));
    vaultManager.burnDyad(id, 1e20);
  }

  ///////////////////////////
  // redeemDyad
  function test_redeemDyad() public {
    uint id = mintDNft();
    deposit(id, address(vault), 1e22);
    vaultManager.mintDyad(id, 1e20, address(this));
    vaultManager.redeemDyad(id, address(vault), 1e20, RECEIVER);
  }

  ///////////////////////////
  // collatRatio
  function test_collatRatio() public {
    uint id = mintDNft();
    uint cr = vaultManager.collatRatio(id);
    assertEq(cr, type(uint).max);
    deposit(id, address(vault), 1e22);
    vaultManager.mintDyad(id, 1e24, address(this));
    cr = vaultManager.collatRatio(id);
    assertEq(cr, 10000000000000000000);
  }

  ///////////////////////////
  // getTotalUsdValue
  function test_getTotalUsdValue() public {
    uint id = mintDNft();
    uint DEPOSIT = 1e22;
    deposit(id, address(vault), DEPOSIT);
    uint usdValue = vaultManager.getTotalUsdValue(id);
    assertEq(usdValue, 10000000000000000000000000);
  }
}
