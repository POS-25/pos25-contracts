// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Pos25 is
    AccessControlUpgradeable,
    PausableUpgradeable,
    OwnableUpgradeable
{

    /**
     *      @dev Define variables in contract
     */
    address internal nativeToken= 0x0000000000000000000000000000000000000000;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    /**
     *      @dev Define events that contract will emit
     */
    event PosWithdraw(address toAddress, uint256 amount);
    event PosDeposit(address fromAddress, address tokenAddress, uint256 amount, string callBackData);
    event PosTransfer(address toAddress, address tokenAddress, uint256 amount);

    // mapping address collection with (coin token with balance)
    mapping(address => uint256) internal balancePos;

    /**
     * @notice Checks if address is a contract
     * @dev It prevents contract from being targetted
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     *      @dev Modifiers using in contract
     */
    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /**
    * The 'initialize' function is a public entry point used to set up the initial roles of the contract.
    * It grants the DEFAULT_ADMIN_ROLE, PAUSER_ROLE, WITHDRAW_ROLE, and TRANSFER_ROLE to the sender during contract initialization.
    */
    function initialize() public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(WITHDRAW_ROLE, msg.sender);
        _grantRole(TRANSFER_ROLE, msg.sender);
    }

    // Function to receive Ether
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    /**
    * The 'getBalanceNative' function is a public entry point that allows wallets with the DEFAULT_ADMIN_ROLE to check the balance of native tokens held by the contract.
    * Return the balance of native tokens held by the contract.
    */
    function getBalanceNative() public view onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        return address(this).balance;
    }

    /**
    * The 'depositNative' function is a public entry point that facilitates the deposit of a specified '_amount' of native tokens.
    * 
    * @param _amount: the amount of native tokens to deposit,
    * @param _callBackData: additional data for the deposit.
    * 
    * It initiates the deposit by transferring '_amount' of native tokens to the contract.
    * An 'PosDeposit' event is then emitted, recording the sender's address, the deposited amount, and any provided callback data.
    */
    function depositNative(
        uint256 _amount,
        string memory _callBackData
    ) payable external notContract {
        _depositNative(_amount, _callBackData);
    }

    /**
    * The '_depositNative' function is an internal helper function that handles the logic for depositing native tokens.
    * 
    * @param _amount: the amount of native tokens to deposit,
    * @param _callBackData: additional data for the deposit.
    * 
    * It checks if the provided amount matches the sent value, transfers the native tokens to the contract,
    * and emits a 'PosDeposit' event with the sender's address, the deposited amount, and any provided callback data.
    */
    function _depositNative(
        uint256 _amount,
        string memory _callBackData
    ) internal {
        require(_amount == msg.value, "Call amount and sender amount not match");
        payable (address(this)).transfer(_amount);
        emit PosDeposit(msg.sender, nativeToken, _amount, _callBackData);
    }
    
    /**
    * The 'depositToken' function is a public entry point that facilitates the deposit of a specified '_amount' of a given ERC-20 token.
    * 
    * @param _tokenAddress: the address of the ERC-20 token,
    * @param _amount: the amount of ERC-20 tokens to deposit,
    * @param _callBackData: additional data for the deposit.
    * 
    * It initiates the deposit by transferring '_amount' of the specified ERC-20 token from the sender to the contract.
    * An 'PosDeposit' event is then emitted, recording the sender's address, the deposited amount, and any provided callback data.
    */
    function depositToken(
        address _tokenAddress,
        uint256 _amount,
        string memory _callBackData
    ) external notContract {
        _depositToken(_tokenAddress, _amount, _callBackData);
    }

    /**
    * The '_depositToken' function is an internal helper function that handles the logic for depositing ERC-20 tokens.
    * 
    * @param _tokenAddress: the address of the ERC-20 token,
    * @param _amount: the amount of ERC-20 tokens to deposit,
    * @param _callBackData: additional data for the deposit.
    * 
    * It checks if the sender has sufficient balance, transfers '_amount' of the specified ERC-20 token to the contract,
    * updates the balancePos mapping, and emits a 'PosDeposit' event with the sender's address, the deposited amount, and any provided callback data.
    */
    function _depositToken(
        address _tokenAddress,
        uint256 _amount,
        string memory _callBackData
    ) internal {
        require(
            IERC20(_tokenAddress).balanceOf(msg.sender) >= _amount,
            "Not enough tokens to deposit"
        );
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        balancePos[_tokenAddress] += _amount;
        emit PosDeposit(msg.sender, _tokenAddress, _amount, _callBackData);
    }

    /**
    * The 'withdrawToken' function is a public entry point that allows wallets with the WITHDRAW_ROLE to withdraw a specified '_amount' of a given ERC-20 token or native token.
    * 
    * @param _tokenAddress: the address of the ERC-20 token or native token,
    * @param _amount: the amount of ERC-20 tokens or native tokens to withdraw.
    * 
    * It initiates the withdrawal by calling the internal 'withdraw' function, transferring '_amount' of the specified token to the sender.
    * The 'PosWithdraw' event is then emitted, recording the sender's address and the withdrawn amount.
    */
    function withdrawToken(
        address _tokenAddress,
        uint256 _amount
    ) external onlyRole(WITHDRAW_ROLE) {
        withdraw(
            _amount,
            _tokenAddress
        );
    }

    /**
    * The 'withdraw' function is an internal helper function that handles the logic for withdrawing tokens, whether they are native tokens or ERC-20 tokens.
    * 
    * @param _amount: the amount of tokens to withdraw,
    * @param _tokenAddress: the address of the token (could be an ERC-20 token or native token).
    * 
    * It checks if the token to withdraw is the native token or an ERC-20 token and performs the withdrawal accordingly.
    * For ERC-20 tokens, it checks if the contract has sufficient balance, transfers '_amount' of the specified ERC-20 token to the sender,
    * updates the balancePos mapping, and emits a 'PosWithdraw' event with the sender's address and the withdrawn amount.
    * For native tokens, it checks if the contract has sufficient balance, transfers '_amount' of native tokens to the sender,
    * and emits a 'PosWithdraw' event with the sender's address and the withdrawn amount.
    */
    function withdraw(
        uint256 _amount,
        address _tokenAddress
    ) internal {
        if(_tokenAddress != nativeToken) {
            require(
                balancePos[_tokenAddress] >= _amount, 
                "Not enough tokens to withdraw"
            );
            IERC20(_tokenAddress).transfer(msg.sender, _amount);
            balancePos[_tokenAddress] -= _amount;
        } else {
            require(_amount <= getBalanceNative(), "Error: amount > balance native token");
            payable (msg.sender).transfer(_amount);
        }

        emit PosWithdraw(msg.sender, _amount); 
    }

    /**
    * The 'transferToken' function is a public entry point that allows wallets with the TRANSFER_ROLE to transfer a specified '_amount' of a given ERC-20 token or native token to a specified '_toAddress'.
    * 
    * @param _toAddress: the recipient's address,
    * @param _tokenAddress: the address of the ERC-20 token or native token,
    * @param _amount: the amount of ERC-20 tokens or native tokens to transfer.
    * 
    * It initiates the transfer by calling the internal 'transfer' function, transferring '_amount' of the specified ERC-20 token or native token to the recipient.
    * The 'PosTransfer' event is then emitted, recording the recipient's address, the transferred amount, and the token address.
    */
    function transferToken(
        address _toAddress,
        address _tokenAddress,
        uint256 _amount
    ) external onlyRole(TRANSFER_ROLE) {
        transfer(
            _toAddress,
            _tokenAddress,
            _amount
        );
    }

    /**
    * The 'transfer' function is an internal helper function that handles the logic for transferring tokens, whether they are native tokens or ERC-20 tokens.
    * 
    * @param _toAddress: the recipient's address,
    * @param _tokenAddress: the address of the token (could be an ERC-20 token or native token),
    * @param _amount: the amount of tokens to transfer.
    * 
    * It checks if the token to transfer is the native token or an ERC-20 token and performs the transfer accordingly.
    * For ERC-20 tokens, it checks if the contract has sufficient balance, transfers '_amount' of the specified ERC-20 token to the recipient,
    * updates the balancePos mapping, and emits a 'PosTransfer' event with the recipient's address, the transferred amount, and the token address.
    * For native tokens, it checks if the contract has sufficient balance, transfers '_amount' of native tokens to the recipient,
    * and emits a 'PosTransfer' event with the recipient's address, the transferred amount, and the native token address.
    */
    function transfer(
        address _toAddress,
        address _tokenAddress,
        uint256 _amount
    ) internal {
        if(_toAddress != nativeToken) {
            require(
                balancePos[_tokenAddress] >= _amount, 
                "Not enough tokens to transfer"
            );
            IERC20(_tokenAddress).transfer(_toAddress, _amount);
            balancePos[_tokenAddress] -= _amount;
        } else {
            require(_amount <= getBalanceNative(), "Error: amount > balance native token");
            payable (_toAddress).transfer(_amount);
        }
        emit PosTransfer(_toAddress, _tokenAddress, _amount); 
    }

    /**
    * The 'grantRoleWithdraw' function is a public entry point that allows wallets with the DEFAULT_ADMIN_ROLE to grant the WITHDRAW_ROLE to a specified 'account'.
    * 
    * @param account: the address to grant the WITHDRAW_ROLE.
    * 
    * It grants the WITHDRAW_ROLE to the specified 'account'.
    */
    function grantRoleWithdraw(address account) external  onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(WITHDRAW_ROLE, account);
    }

    /**
    * The 'grantRoleTransfer' function is a public entry point that allows wallets with the DEFAULT_ADMIN_ROLE to grant the TRANSFER_ROLE to a specified 'account'.
    * 
    * @param account: the address to grant the TRANSFER_ROLE.
    * 
    * It grants the TRANSFER_ROLE to the specified 'account'.
    */
    function grantRoleTransfer(address account) external  onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(TRANSFER_ROLE, account);
    }

    /**
    * The 'pause' function is a public entry point that allows wallets with the PAUSER_ROLE to pause the contract.
    * 
    * It pauses the contract, preventing certain functions from being executed.
    */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
    * The 'unpause' function is a public entry point that allows wallets with the PAUSER_ROLE to unpause the contract.
    * 
    * It unpauses the contract, allowing normal operation.
    */
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
}