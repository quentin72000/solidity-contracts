// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Splitter
 * @dev Split a sent value to added targets equaly.
 */
contract Splitter {
    mapping (address => address[]) targets;
    mapping (address => uint) balances;

    /**
     * @dev Return your current balance
     * @return value of your balance
     */
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function refundBalance() public {
        require(balances[msg.sender] > 0, "Balance is zero.");
        (bool sent,) = msg.sender.call{value: balances[msg.sender]}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0; 
    }

     /**
     * @dev Set targets to the targets list
     * @param _targets addresses to set to the target list
     */
    function setTargets(address[] calldata _targets) public {
        require(_targets.length > 0, "Targets list cannot be empty");
        targets[msg.sender] = _targets;
    }

    /**
     * @dev Add targets to the targets list
     * @param _targets addresses to add to the target list
     */
    function addTargets(address[] calldata _targets) public {
        require(_targets.length > 0, "Targets list cannot be empty");
        for (uint i=0; i<_targets.length; i++) {
            targets[msg.sender].push(_targets[i]);
        }
    }

    /**
     * @dev Split and send the sent ether ammount to the targets adresses
     */
    function split() external {
        address[] memory _targets = targets[msg.sender];
        uint senderBalance = balances[msg.sender];
        require(_targets.length > 0, "No target set");
        require(senderBalance > 0, "Balance is zero.");

        uint sendAmmount = senderBalance / _targets.length;
        require(sendAmmount > 0, "Amount too small to split");
        
        balances[msg.sender] = senderBalance % _targets.length; // Set leftover to sender balance

        for(uint i=0; i< _targets.length; i++){
            (bool sent,) = _targets[i].call{value: sendAmmount}("");
            require(sent, "Failed to send Ether");
        }
    }

    /**
     * @dev Return targets list
     * @return value of 'targets'
     */
    function getTargets() public view returns (address[] memory){
        return targets[msg.sender];
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
    }

    fallback() external payable {
        balances[msg.sender] += msg.value;
    }
}