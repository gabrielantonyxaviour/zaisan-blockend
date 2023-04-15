pragma solidity ^0.8.14;

import "./lib/libs/zk-connect/ZkConnectLib.sol";

contract SismoTest is ZkConnect {
    constructor(bytes16 appId) ZkConnect(appId) {}

    function verifyProof(
        bytes memory zkConnectResponse,
        bytes memory encodedParams,
        bytes16 groupId
    ) public returns (bool) {
        verify({
            responseBytes: zkConnectResponse,
            authRequest: buildAuth({authType: AuthType.ANON}),
            claimRequest: buildClaim({groupId: groupId}),
            messageSignatureRequest: encodedParams
        });
        return true;
    }
}
