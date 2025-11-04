// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BaseRollPayroll (UUPS Upgradeable)
 * @notice Minimal payroll demo for Base (mainnet / testnet). Funds are held on the contract
 *         and distributed to configured payees in native ETH or ERC20. Owner controls roster.
 *         This is a demo/MVP and NOT production-audited code.
 */
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

contract BaseRollPayroll is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    struct Payee {
        bool active;
        uint256 ethAmount;     // amount per cycle in wei
        address token;         // optional ERC20 token address (0 for none)
        uint256 tokenAmount;   // amount per cycle in token's decimals
    }

    mapping(address => Payee) public payees;
    address[] public roster;

    event PayeeAdded(address indexed account, uint256 ethAmount, address token, uint256 tokenAmount);
    event PayeeUpdated(address indexed account, uint256 ethAmount, address token, uint256 tokenAmount, bool active);
    event Paid(address indexed account, uint256 ethAmount, address token, uint256 tokenAmount);
    event Rescue(address indexed token, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    // --- Admin: roster management ---

    function addOrUpdatePayee(
        address account,
        uint256 ethAmount,
        address token,
        uint256 tokenAmount,
        bool active
    ) external onlyOwner {
        require(account != address(0), "invalid");
        if (!payees[account].active && active) {
            roster.push(account);
        }
        payees[account] = Payee({active: active, ethAmount: ethAmount, token: token, tokenAmount: tokenAmount});
        if (!active) {
            // leave in roster array; lookups read 'active' flag
        }
        emit PayeeUpdated(account, ethAmount, token, tokenAmount, active);
    }

    function addPayee(address account, uint256 ethAmount) external onlyOwner {
        require(account != address(0), "invalid");
        require(!payees[account].active, "exists");
        payees[account] = Payee({active: true, ethAmount: ethAmount, token: address(0), tokenAmount: 0});
        roster.push(account);
        emit PayeeAdded(account, ethAmount, address(0), 0);
    }

    function rosterLength() external view returns (uint256) {
        return roster.length;
    }

    // --- Payouts ---

    /**
     * @notice Pays everyone currently active according to configured amounts.
     * @dev Owner-triggered for simplicity. In production you'd use automations.
     */
    function processPayroll(uint256 maxCount) external onlyOwner {
        uint256 count = 0;
        for (uint256 i = 0; i < roster.length && count < maxCount; i++) {
            address a = roster[i];
            Payee memory p = payees[a];
            if (!p.active) continue;

            if (p.ethAmount > 0) {
                (bool ok, ) = payable(a).call{value: p.ethAmount}("");
                require(ok, "ETH transfer failed");
            }
            if (p.token != address(0) && p.tokenAmount > 0) {
                require(IERC20(p.token).transfer(a, p.tokenAmount), "ERC20 transfer failed");
            }
            emit Paid(a, p.ethAmount, p.token, p.tokenAmount);
            count++;
        }
    }

    // --- Funding / Rescue ---

    receive() external payable {}

    function rescueERC20(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(owner(), amount), "transfer failed");
        emit Rescue(token, amount);
    }

    function rescueETH(uint256 amount) external onlyOwner {
        (bool ok, ) = payable(owner()).call{value: amount}("");
        require(ok, "transfer failed");
        emit Rescue(address(0), amount);
    }
}
