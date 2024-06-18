// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Splitter
 * @dev Split a sent value to added targets equaly.
 */
contract SplitterWithoutBalance {
    mapping (address => address[]) targets;

     /**
     * @dev Set targets to the targets list
     * @param _targets addresses to set to the target list
     */
    function setTargets(address[] calldata _targets) public {
        targets[msg.sender] = _targets;
    }

    /**
     * @dev Add targets to the targets list
     * @param _targets addresses to add to the target list
     */
    function addTargets(address[] calldata _targets) public {
        for (uint i=0; i<_targets.length; i++) {
            targets[msg.sender].push(_targets[i]);
        }
    }

    /**
     * @dev Split and send the sent ether ammount to the targets adresses
     */
    function split() external payable {
        address[] memory _targets = targets[msg.sender];
        require(_targets.length > 0, "No target set");
        require(msg.value > 0, "Value is zero.");

        uint sendAmmount = msg.value / _targets.length;
        require(sendAmmount > 0, "Amount too small to split");

        for(uint i=0; i< _targets.length; i++){
            (bool sent,) = _targets[i].call{value: sendAmmount}("");
            require(sent, "Failed to send Ether");
        }

        uint256 leftover = msg.value % _targets.length;
        if (leftover > 0) {
            payable(msg.sender).transfer(leftover);
        }

        
    }

    /**
     * @dev Return targets list
     * @return value of 'targets'
     */
    function getTargets() public view returns (address[] memory){
        return targets[msg.sender];
    }
}