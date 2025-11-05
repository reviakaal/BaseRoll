// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {SafeERC20Upgradeable, IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract BaseRollPayroll is Initializable, UUPSUpgradeable, Ownable2StepUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    struct Payee {
        bool active;
        uint256 ethAmount;
        address token;
        uint256 tokenAmount;
    }

    mapping(address => Payee) public payees;
    address[] public roster;

    event PayeeAdded(address indexed account, uint256 ethAmount, address token, uint256 tokenAmount);
    event PayeeUpdated(address indexed account, uint256 ethAmount, address token, uint256 tokenAmount, bool active);
    event Paid(address indexed account, uint256 ethAmount, address token, uint256 tokenAmount);
    event Rescue(address indexed token, uint256 amount);

    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable2Step_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        _transferOwnership(initialOwner);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function addOrUpdatePayee(
        address account,
        uint256 ethAmount,
        address token,
        uint256 tokenAmount,
        bool active
    ) external onlyOwner {
        require(account != address(0), "invalid");
        bool wasActive = payees[account].active;
        payees[account] = Payee({active: active, ethAmount: ethAmount, token: token, tokenAmount: tokenAmount});
        if (active && !wasActive) {
            roster.push(account);
            emit PayeeAdded(account, ethAmount, token, tokenAmount);
        } else {
            emit PayeeUpdated(account, ethAmount, token, tokenAmount, active);
        }
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

    function processPayroll(uint256 maxCount) external whenNotPaused nonReentrant onlyOwner {
        require(maxCount > 0, "zero");
        uint256 paid = 0;
        uint256 len = roster.length;
        for (uint256 i = 0; i < len && paid < maxCount; i++) {
            address a = roster[i];
            Payee memory p = payees[a];
            if (!p.active) continue;
            if (p.ethAmount > 0) {
                (bool ok, ) = payable(a).call{value: p.ethAmount}("");
                require(ok, "eth");
            }
            if (p.token != address(0) && p.tokenAmount > 0) {
                IERC20Upgradeable(p.token).safeTransfer(a, p.tokenAmount);
            }
            emit Paid(a, p.ethAmount, p.token, p.tokenAmount);
            paid++;
        }
    }

    receive() external payable {}

    function rescueERC20(address token, uint256 amount) external onlyOwner {
        IERC20Upgradeable(token).safeTransfer(owner(), amount);
        emit Rescue(token, amount);
    }

    function rescueETH(uint256 amount) external onlyOwner {
        (bool ok, ) = payable(owner()).call{value: amount}("");
        require(ok, "eth");
        emit Rescue(address(0), amount);
    }

    uint256[44] private __gap;
}
