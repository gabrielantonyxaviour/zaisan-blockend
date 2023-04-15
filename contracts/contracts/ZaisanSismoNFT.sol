// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IMessageRecipient.sol";

contract ZaisanSismoNFT is ERC721, ERC721URIStorage, IMessageRecipient {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string public badgeTokenURI;
    address public constant MAILBOX_ADDRESS =
        0xCC737a94FecaeC165AbCf12dED095BB13F037685;
    address public promoter;
    address public immutable mainContract;

    event ClaimedPromotion(address claimer);

    constructor(
        string memory _tokenURI,
        address _promoterAddress,
        address _mainContract
    ) ERC721("ZaisaNFT", "ZFT") {
        badgeTokenURI = _tokenURI;
        promoter = _promoterAddress;
        mainContract = _mainContract;
    }

    modifier onlyPromoter() {
        require(msg.sender == promoter);
        _;
    }

    modifier onlyMailbox() {
        require(msg.sender == MAILBOX_ADDRESS);
        _;
    }
    modifier onlyMainContract(address sender) {
        require(sender == mainContract, "Invalid");
        _;
    }

    function handle(
        uint32,
        bytes32 sender,
        bytes calldata _body
    ) external onlyMailbox onlyMainContract(address(uint160(uint256(sender)))) {
        address claimer = abi.decode(_body, (address));
        safeMint(claimer);
    }

    function safeMint(address to) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, badgeTokenURI);
        emit ClaimedPromotion(to);
    }

    function setTokenURI(string memory _tokenURI) public onlyPromoter {
        badgeTokenURI = _tokenURI;
    }

    // Soulbound Token
    function transferFrom(address, address, uint256) public pure override {
        revert("Cannot transfer");
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256) internal pure override(ERC721, ERC721URIStorage) {
        revert("Disabled");
        // super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
