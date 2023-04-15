// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./interfaces/IMessageRecipient.sol";
import "./ZaisanSismoNFT.sol";

contract Receiver is IMessageRecipient {
    mapping(address => address) public latestPromotionDeployment;
    address public constant MAILBOX_ADDRESS =
        0xCC737a94FecaeC165AbCf12dED095BB13F037685;

    event PromotionNFTDeployed(address promotionNFTAddress);

    modifier onlyMailbox() {
        require(msg.sender == MAILBOX_ADDRESS);
        _;
    }

    address public immutable mainContract;

    constructor(address _mainContract) {
        mainContract = _mainContract;
    }

    function handle(
        uint32,
        bytes32,
        bytes calldata _body
    ) external onlyMailbox {
        (
            string memory _badgeURI,
            address _promoterAddress,
            address _mainContract,
            bytes32 _salt
        ) = abi.decode(_body, (string, address, address, bytes32));
        require(_mainContract == mainContract, "Invalid");

        ZaisanSismoNFT promotion = (new ZaisanSismoNFT){salt: _salt}(
            _badgeURI,
            _promoterAddress,
            mainContract
        );
        emit PromotionNFTDeployed(address(promotion));
    }

    function getLatestPromotionDeployment(
        address promoter
    ) public view returns (address) {
        return latestPromotionDeployment[promoter];
    }

    function bytes32ToString(
        bytes32 _bytes32
    ) public pure returns (string memory) {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}
