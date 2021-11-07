// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// To read more about NFTs, checkout the ERC721 standard:
// https://eips.ethereum.org/EIPS/eip-721 

/**
NOTE: THIS WILL NOT BE AUTOMATICALLY COMPILED.
If you want it to compile, either import it into contract.sol or copy and paste the contract directly into there!
**/

contract SimpleNFT is ERC721URIStorage, Ownable {
		uint256 public tokenCounter = 0;
		string public userTokenURI;
		string public setUserTokenURI;

    constructor(string memory _userTokenURI, address recipient, uint256 amount) ERC721("MINTLER", "MINTR") {
			userTokenURI = _userTokenURI;
            mint(recipient, amount);
    }

    function mint(address recipient, uint256 amount) public returns (uint256) {
			while (tokenCounter < amount ) {
        _mint(recipient, tokenCounter);

        _setTokenURI(tokenCounter, userTokenURI);

        tokenCounter = tokenCounter + 1;
            }
        return tokenCounter;
    }

	function initializeSimpleNFT(string memory _tokenURI) public {
        userTokenURI = _tokenURI;
    }

	function getURI() public view returns (string memory) {
		return userTokenURI;
	}
}