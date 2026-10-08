// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ChecksEffectsVault, IVault, ReentrancyProbe, VulnerableVault} from "../src/ReentrancyLab.sol";

interface Vm {
    function deal(address account, uint256 newBalance) external;
}

contract ReentrancyLabTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function testProbeDrainsVulnerableVault() external {
        vm.deal(address(this), 6 ether);
        VulnerableVault vault = new VulnerableVault();
        vault.deposit{value: 5 ether}();
        ReentrancyProbe probe = new ReentrancyProbe(IVault(address(vault)));

        probe.attack{value: 1 ether}();

        require(address(vault).balance == 0, "vault should be drained");
        require(address(probe).balance == 6 ether, "probe should receive all funds");
    }

    function testChecksEffectsStopsRepeatedWithdrawal() external {
        vm.deal(address(this), 6 ether);
        ChecksEffectsVault vault = new ChecksEffectsVault();
        vault.deposit{value: 5 ether}();
        ReentrancyProbe probe = new ReentrancyProbe(IVault(address(vault)));

        probe.attack{value: 1 ether}();

        require(address(vault).balance == 5 ether, "vault should retain victim funds");
        require(address(probe).balance == 1 ether, "probe should only withdraw its deposit");
    }
}
