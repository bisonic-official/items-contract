//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.18;

interface IRuniverseItem {
    event RuniverseItemMinted(address to, uint256 tokenId);

    function mintTokenId(address recipient, uint256 tokenId) external;
}