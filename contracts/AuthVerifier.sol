// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "./IAuthVerifier.sol";
import "./KeyInfrastructure.sol";

contract AuthVerifier is IAuthVerifier, KeyInfrastructure {
    bytes32 private constant EIP712DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // solhint-disable max-line-length
    bytes32 private constant FUNCTIONCALL_TYPEHASH =
        keccak256("FunctionCall(bytes4 functionSignature,address target,address caller,bytes parameters)");

    // solhint-disable max-line-length
    bytes32 private constant TOKEN_TYPEHASH =
        keccak256(
            "AuthToken(uint256 expiry,FunctionCall functionCall)FunctionCall(bytes4 functionSignature,address target,address caller,bytes parameters)"
        );

    // solhint-disable var-name-mixedcase
    bytes32 public DOMAIN_SEPARATOR;

    constructor(address root) KeyInfrastructure(root) {
        DOMAIN_SEPARATOR = hash(
            EIP712Domain({
                name: "Ethereum Access Token",
                version: "1",
                chainId: block.chainid,
                verifyingContract: address(this)
            })
        );
    }

    function hash(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712DOMAIN_TYPEHASH,
                    keccak256(bytes(eip712Domain.name)),
                    keccak256(bytes(eip712Domain.version)),
                    eip712Domain.chainId,
                    eip712Domain.verifyingContract
                )
            );
    }

    function hash(FunctionCall memory call) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    FUNCTIONCALL_TYPEHASH,
                    call.functionSignature,
                    call.target,
                    call.caller,
                    keccak256(call.parameters)
                )
            );
    }

    function hash(AuthToken memory token) internal pure returns (bytes32) {
        return keccak256(abi.encode(TOKEN_TYPEHASH, token.expiry, hash(token.functionCall)));
    }

    function verify(
        AuthToken memory token,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view override returns (bool) {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hash(token)));

        require(token.expiry > block.timestamp, "AuthToken: has expired");
        return ecrecover(digest, v, r, s) == _issuer;
    }
}
