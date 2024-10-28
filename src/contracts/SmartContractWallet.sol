// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract SmartContractWallet {
    address payable owner;

    mapping(address => uint256) public allowance;
    mapping(address => bool) public isAllowedToSend;

    mapping(address => bool) public guardian;
    address payable nextOwner;
    uint256 guardiansResetCount;
    uint256 public constant confirmationsFromGuardiansForReset = 3;

    // Events to log when actions occur
    event AllowanceSet(address indexed allowedBy, address indexed allowedTo, uint256 amount);
    event TransferMade(address indexed from, address indexed to, uint256 amount, bytes payload);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner, aborting!");
        _;
    }

    modifier onlyGuardian() {
        require(guardian[msg.sender], "You are no guardian, aborting");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    function proposeNewOwner(address payable newOwner) public onlyGuardian {
        if (nextOwner != newOwner) {
            nextOwner = newOwner;
            guardiansResetCount = 0;
        }

        guardiansResetCount++;

        if (guardiansResetCount >= confirmationsFromGuardiansForReset) {
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function addGuardian(address _guardian) public onlyOwner {
        require(_guardian != address(0), "Invalid guardian address");
        require(_guardian != owner, "The owner shouldn't be a guardian");
        require(!guardian[_guardian], "Address is already a guardian");
        guardian[_guardian] = true;
    }

    function removeGuardian(address _guardian) public onlyOwner {
        require(guardian[_guardian], "Address is not a guardian");
        guardian[_guardian] = false;
    }

    function setAllowance(address _from, uint256 _amount) public onlyOwner {
        allowance[_from] = _amount;
        isAllowedToSend[_from] = true;
        emit AllowanceSet(msg.sender, _from, _amount); // Emit the AllowanceSet event
    }

    function denySending(address _from) public onlyOwner {
        isAllowedToSend[_from] = false;
    }

    function transfer(
        address payable _to,
        uint256 _amount,
        bytes memory payload
    ) public returns (bytes memory) {
        require(
            _amount <= address(this).balance,
            "Can't send more than the contract owns, aborting."
        );
        if (msg.sender != owner) {
            require(
                isAllowedToSend[msg.sender],
                "You are not allowed to send any transactions, aborting"
            );
            require(
                allowance[msg.sender] >= _amount,
                "You are trying to send more than you are allowed to, aborting"
            );
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(
            payload
        );
        require(success, "Transaction failed, aborting");

        // Emit the TransferMade event
        emit TransferMade(msg.sender, _to, _amount, payload);

        return returnData;
    }

    function getWalletFunds() public view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}