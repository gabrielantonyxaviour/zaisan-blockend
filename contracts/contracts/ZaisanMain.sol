// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./lib/libs/zk-connect/ZkConnectLib.sol";
import "./interfaces/IInterchainQueryRouter.sol";
import "./interfaces/IMailbox.sol";
import {ByteHasher} from "./helpers/ByteHasher.sol";
import {IWorldID} from "./interfaces/IWorldID.sol";
import "./interfaces/IInterchainGasPaymaster.sol";
import "./interfaces/IReceiver.sol";
import "./ZaisanSismoNFT.sol";

contract ZaisanMain is ReentrancyGuard, ZkConnect {
    using ECDSA for bytes32;
    using ByteHasher for bytes;

    enum ClaimState {
        DOES_NOT_EXIST,
        AVAILABLE,
        EXHAUSTED,
        WAITING
    }

    struct Receiver {
        bytes32 destinationReceiverAddress;
        uint relayerGas;
        bool isExists;
    }

    struct Promotion {
        address promotionAddress;
        address creator;
        uint createdAt;
        uint32 destinationDomain;
        uint claimsPerPerson;
        uint ethGasLeft;
        bytes16 groupId;
    }

    struct PromotionClaim {
        uint32 destinationDomain;
        address promotionAddress;
        uint claimsCount;
        ClaimState state;
    }

    struct PromotionParams {
        uint claimsPerPerson;
        string badgeURI;
        string postId;
        address tokenAddress;
        bytes16 groupId;
        uint32 destinationDomain;
        uint salt;
    }

    mapping(bytes32 => Promotion) public promotions; // Promotion Id => sismoPromotions
    mapping(bytes32 => mapping(address => PromotionClaim)) public claims; // Promotion Id => Claimer => Claim

    mapping(uint32 => Receiver) public chains; // Destination Chain to Receiver Data

    IMailbox public constant mailbox =
        IMailbox(0xCC737a94FecaeC165AbCf12dED095BB13F037685);
    IInterchainGasPaymaster public constant igp =
        IInterchainGasPaymaster(0xF90cB82a76492614D07B82a7658917f3aC811Ac1);
    IInterchainQueryRouter public constant iqsRouter =
        IInterchainQueryRouter(0xF782C6C4A02f2c71BB8a1Db0166FAB40ea956818);
    IWorldID public constant worldIDStaging =
        IWorldID(0xABB70f7F39035586Da57B3c8136035f87AC0d2Aa);

    bytes private worldCoinAppId;
    address private immutable contractDeployer;

    constructor(
        bytes16 sismoAppId,
        bytes memory _worldCoinAppId
    ) ZkConnect(sismoAppId) {
        worldCoinAppId = _worldCoinAppId;
        contractDeployer = msg.sender;
    }

    event GasTankRefunded(bytes32 promotionId, uint256 amount);
    event PromotionCreated(
        bytes32 promotionId,
        bytes16 groupId,
        uint32 destinationDomain,
        uint claimsPerPerson,
        string postId,
        address tokenAddress,
        uint ethGasLeft,
        string badgeURI,
        address creator
    );

    event PromotionClaimed(
        bytes32 promotionId,
        address claimer,
        uint claimsCount,
        uint ethGasLeft,
        uint claimedAt
    );

    event GasTankFilled(bytes32 _promotionId, uint ethGasLeft);

    // ERC 20 - Token Count balanceOf(address)=>(uint)
    // ERC721 - Token Count balanceOf(address)=>(uint), Specific Token Ownership ownerOf(uint)=>address
    // ERC1155 - Specific Token Count balanceOf(address,uint)=>(uint)

    function _claimPreCheck(PromotionClaim memory _claim) internal pure {
        require(_claim.state != ClaimState.EXHAUSTED, "No more claims");
        require(
            _claim.state != ClaimState.WAITING,
            "Processing previous claim"
        );
    }

    function addChain(
        uint32 destinationDomain,
        address destinationReceiver,
        uint relayerGas
    ) public {
        require(msg.sender == contractDeployer, "Invalid");
        chains[destinationDomain] = Receiver(
            addressToBytes32(destinationReceiver),
            relayerGas,
            true
        );
    }

    function createPromotion(
        PromotionParams memory promotionParams
    ) public payable {
        require(chains[promotionParams.destinationDomain].isExists, "Invalid");
        require(promotionParams.claimsPerPerson > 0, "zero claims");
        bytes32 _promotionId = keccak256(
            abi.encodePacked(
                promotionParams.groupId,
                promotionParams.badgeURI,
                promotionParams.destinationDomain,
                block.timestamp
            )
        );
        require(promotions[_promotionId].createdAt == 0, "Promotion exists");

        uint256 quotedPayment = getQuotedPayment(
            promotionParams.destinationDomain
        );
        require(msg.value >= quotedPayment, "Insufficient gas");

        // 3. Pay for Interchain Gas
        igp.payForGas{value: quotedPayment}(
            mailbox.dispatch(
                promotionParams.destinationDomain,
                chains[promotionParams.destinationDomain]
                    .destinationReceiverAddress,
                abi.encode(
                    promotionParams.badgeURI,
                    msg.sender,
                    address(this),
                    bytes32(promotionParams.salt)
                )
            ),
            promotionParams.destinationDomain,
            chains[promotionParams.destinationDomain].relayerGas,
            msg.sender
        );

        // 4. Update State Variables
        promotions[_promotionId] = Promotion(
            _getAddress(
                promotionParams.destinationDomain,
                promotionParams.badgeURI,
                msg.sender,
                promotionParams.salt
            ),
            msg.sender,
            block.timestamp,
            promotionParams.destinationDomain,
            promotionParams.claimsPerPerson,
            msg.value - quotedPayment,
            promotionParams.groupId
        );

        // 5. Emit events

        emit PromotionCreated(
            _promotionId,
            promotionParams.groupId,
            promotionParams.destinationDomain,
            promotionParams.claimsPerPerson,
            promotionParams.postId,
            promotionParams.tokenAddress,
            msg.value - quotedPayment,
            promotionParams.badgeURI,
            msg.sender
        );
    }

    function claimPromotion(
        bytes32 _promotionId,
        address claimer,
        bytes memory zkConnectResponse,
        bytes calldata encodedParams,
        uint root,
        uint nullifierHash,
        uint[8] calldata worldcoinProof
    ) public {
        // Verifications
        Promotion memory _promotion = promotions[_promotionId];
        PromotionClaim memory _claim = claims[_promotionId][claimer];
        require(_promotion.createdAt != 0, "Does not exist");
        _claimPreCheck(_claim);

        // Sismo verification
        verify({
            responseBytes: zkConnectResponse,
            authRequest: buildAuth({authType: AuthType.ANON}),
            claimRequest: buildClaim({groupId: _promotion.groupId}),
            messageSignatureRequest: encodedParams
        });

        // Worlcoin Verification
        worldIDStaging.verifyProof(
            root,
            1,
            abi.encodePacked(claimer).hashToField(),
            nullifierHash,
            abi.encodePacked(worldCoinAppId).hashToField(),
            worldcoinProof
        );

        bytes memory messsage = abi.encode(claimer);
        bytes32 _messageId = mailbox.dispatch(
            _promotion.destinationDomain,
            addressToBytes32(_promotion.promotionAddress),
            messsage
        );
        uint256 quotedPayment = getQuotedPayment(_promotion.destinationDomain);
        require(_promotion.ethGasLeft > quotedPayment, "Insufficient gas");
        promotions[_promotionId].ethGasLeft -= quotedPayment;

        igp.payForGas{value: quotedPayment}(
            _messageId,
            _promotion.destinationDomain,
            chains[_promotion.destinationDomain].relayerGas,
            msg.sender
        );
        if (_claim.claimsCount + 1 == _promotion.claimsPerPerson) {
            claims[_promotionId][claimer] = PromotionClaim(
                _promotion.destinationDomain,
                _promotion.promotionAddress,
                _claim.claimsCount + 1,
                ClaimState.EXHAUSTED
            );
        } else {
            claims[_promotionId][claimer] = PromotionClaim(
                _promotion.destinationDomain,
                _promotion.promotionAddress,
                _claim.claimsCount + 1,
                ClaimState.AVAILABLE
            );
        }

        emit PromotionClaimed(
            _promotionId,
            msg.sender,
            _claim.claimsCount + 1,
            _promotion.ethGasLeft - quotedPayment,
            block.timestamp
        );
    }

    function fillGas(bytes32 _promotionId) public payable {
        require(promotions[_promotionId].createdAt > 0, "Invalid");
        promotions[_promotionId].ethGasLeft += msg.value;
        emit GasTankFilled(_promotionId, promotions[_promotionId].ethGasLeft);
    }

    function refundGas(bytes32 _promotionId, address _to) public nonReentrant {
        require(promotions[_promotionId].createdAt > 0, "Invalid");

        require(msg.sender == promotions[_promotionId].creator, "Unauthorized");
        require(promotions[_promotionId].ethGasLeft > 0, "No balance");
        (bool success, ) = payable(_to).call{
            value: promotions[_promotionId].ethGasLeft
        }("");
        if (success) {
            uint _gasAmount = promotions[_promotionId].ethGasLeft;
            promotions[_promotionId].ethGasLeft = 0;
            emit GasTankRefunded(_promotionId, _gasAmount);
        } else {
            revert("Failed");
        }
    }

    // GETTERS
    function getQuotedPayment(
        uint32 destinationDomain
    ) public view returns (uint256) {
        uint256 quotedPayment = igp.quoteGasPayment(
            destinationDomain,
            chains[destinationDomain].relayerGas
        );
        return quotedPayment;
    }

    // LIBRARY FUNCTIONS

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function _getAddress(
        uint32 destinationDomain,
        string memory badgeURI,
        address creator,
        uint _salt
    ) internal view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(ZaisanSismoNFT).creationCode,
            abi.encode(badgeURI, msg.sender, creator, address(mailbox))
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                chains[destinationDomain].destinationReceiverAddress,
                bytes32(_salt),
                keccak256(bytecode)
            )
        );

        return address(uint160(uint(hash)));
    }
}
