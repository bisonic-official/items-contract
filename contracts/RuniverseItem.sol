//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract RuniverseItem is ERC721, Ownable {
    /// @notice Address of the valid signer in contract.
    address public signer;

    /// @notice The base URI for the metadata of the tokens
    string public baseTokenURI;

    /**
     * @dev Constructor of the contract.
     * @notice We pass the name and symbol to the ERC721 constructor.
     * @notice We set the valid signer address of contract.
     */
    constructor(
        address _signer,
        string memory _baseURI
    ) ERC721("RuniverseItem", "RITM") {
        signer = _signer;
        baseTokenURI = _baseURI;
    }

    /**
     * @dev Sets the valid signer address of contract.
     * @param _signer Address of the signer.
     */
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    /**
     * @dev Returns the signer address of contract.
     * @return signer Address of the valid signer in contract.
     */
    function getSigner() external view returns (address) {
        return signer;
    }

    /**
     * @dev Returns the URL of a given tokenId
     * @param tokenId uint256 ID of the token to be minted
     * @return string the URL of a given tokenId
     */
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            string.concat(baseTokenURI, Strings.toString(tokenId));
    }

    /**
     * @dev Returns if the token exists.
     * @param tokenId uint256 with the ID of the token.
     * @return exists bool if it exists.
     */
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    /**
     * @dev Returns the base URI of the token.
     * @return baseTokenURI String value of base Token URI.
     */
    function getBaseURI() external view returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @dev Sets a new base URI
     * @param newBaseURI string the new token base URI
     */
    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        baseTokenURI = newBaseURI;
    }

    /**
     * @dev Verifies if the signature corresponds to the signer.
     * @param _message Message to verify with signature.
     * @param _signature Signature used to verify the message.
     * @return bool Returns if the signature is valid or not.
     */
    function verify(
        string memory _message,
        bytes memory _signature
    ) public view returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _signature) == signer;
    }

    /**
     * @dev Returns the message hash that is signed to create the signature.
     * @param _message Message to be hashed.
     * @return bytes32 Hash of the message.
     */
    function getMessageHash(
        string memory _message
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    /**
     * @dev Returns the message hash that is signed to create the signature.
     * @param _messageHash Hash of the message to be signed.
     * @return bytes32 Hash of the message.
     */
    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    /**
     * @dev Split signature and recover signer address.
     * @param _ethSignedMessageHash Hash of the signed message.
     * @param _signature Signature to split.
     * @return address Address of the signer.
     */
    function recover(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) private pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /**
     * @dev Split signature into `r`, `s` and `v` variables, used by recover method.
     * @param _signature Signature to split.
     * @return r
     * @return s
     * @return v
     */
    function splitSignature(
        bytes memory _signature
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_signature.length == 65, "Invalid signature length!");

        assembly {
            // First 32 bytes stores the length of the signature
            r := mload(add(_signature, 32))
            // Next 32 bytes stores the length of the signature
            s := mload(add(_signature, 64))
            // Final byte stores the signature type
            v := byte(0, mload(add(_signature, 96)))
        }
    }

    /**
     * @dev Method to verify a message and mint an RuniverseItem to an address. Used for public minting.
     * @param signature Signature used to verify the message.
     * @param tokenId ID of the token to be minted.
     */
    function verifyAndMint(
        bytes memory signature,
        uint256 tokenId
    ) public {
        string memory message = string.concat(Strings.toHexString(msg.sender), ":" , Strings.toString(tokenId));

        require(    
            this.verify(message, signature),
            "Bad signature"
        );

        _safeMint(msg.sender, tokenId);
    }

    /**
     * @dev Method to mint many RuniverseItems and assign them to an addresses without any requirement. Used for private minting.
     * @param tokenIds uint256[] Tokens to be transferred.
     * @param recipients address[] Addresses where each token will be transferred.
     */
    function ownerMint(
        uint256[] calldata tokenIds,
        address[] calldata recipients
    ) external onlyOwner {
        require(
            tokenIds.length == recipients.length,
            "Arrays should have the same size"
        );
        for (uint256 i = 0; i < recipients.length; ++i) {
            _safeMint(recipients[i], tokenIds[i]);
        }
    }
}
