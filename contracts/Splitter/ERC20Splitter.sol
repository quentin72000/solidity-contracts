// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


/**
 * @title Splitter
 * @dev Split a sent value to added targets equaly.
 */
contract ERC20Splitter {
    mapping (address => address[]) private targets;
    mapping (address => uint) private balances;
    IERC20 private token;

    constructor (address _token) {
        token = IERC20(_token);
    }


    /**
     * @dev Return your current senderBalance
     * @return value of your senderBalance
     */
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    function refundBalance() public {
        uint256 senderBalance = balances[msg.sender];
        require(senderBalance > 0, "Balance is zero.");
        balances[msg.sender] = 0; // Optimistically set senderBalance to zero to prevent reentrancy
        require(token.transfer(msg.sender, senderBalance), "Failed to send token");
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
     * @dev Split and send the sent ether amount to the targets adresses
     */
    function split() external {
        address[] memory _targets = targets[msg.sender];
        uint senderBalance = balances[msg.sender];
        require(_targets.length > 0, "No target set");
        require(senderBalance > 0, "Balance is zero.");

        uint sendAmount = senderBalance / _targets.length;
        require(sendAmount > 0, "Amount too small to split");
        
        balances[msg.sender] = senderBalance % _targets.length; // Set leftover to sender senderBalance
        
        for(uint i=0; i< _targets.length; i++){
            require(token.transfer(_targets[i], sendAmount), "Failed to send tokens");
        }
    }

    /**
     * @dev Return targets list
     * @return value of 'targets'
     */
    function getTargets() public view returns (address[] memory){
        return targets[msg.sender];
    }

    function deposit(uint amount) public {
        require(amount > 0, "Amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), amount), "Failed to transfer tokens");
        balances[msg.sender] += amount;
    }
}