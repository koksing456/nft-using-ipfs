// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract RandomIpfsNFT is ERC721URIStorage, VRFConsumerBaseV2 {
  VRFCoordinatorV2Interface immutable i_vrfCoodinator;
  bytes32 immutable i_gasLaneHashKey;
  uint64 immutable i_subscriptionId; // uses for funding requests.
  uint16 constant REQUEST_CONFIRMATION = 3; // minimum request confirmation
  uint32 constant NUM_WORDS = 1; //number of random number we want
  uint256 constant MAX_CHANCE_VALUE = 100;

  // The limit for how much gas to use for the callback request to your contract's fulfillRandomWords() function.
  // It must be less than the maxGasLimit limit on the coordinator contract.
  // In this example, the fulfillRandomWords() function stores two random values, which cost about 20,000 gas each, so a limit of 100,000 gas is sufficient.
  // Adjust this value for larger reDquests depending on how your fulfillRandomWords() function processes and stores the received random values.
  // If your callbackGasLimit is not sufficient, the callback will fail and your subscription is still charged for the work done to generate your requested random values.
  // gasLaneKeyHash = how quickly we want to pay (max) to send the transaction
  uint32 immutable i_callbackGasLimit;

  address s_owner;
  uint256[] public s_randomsWords;

  mapping(uint256 => address) s_requestIdToSender;
  uint256 s_tokenCounter;
  string[3] s_dogTokensUri;

  constructor(
    address vrfCoordinatorV2,
    bytes32 gasLaneKeyHash,
    uint64 subscriptionId,
    uint32 callbackGasLimit,
    string[3] memory dogTokensUri
  ) ERC721("Random IPFS NFT", "RIN") VRFConsumerBaseV2(vrfCoordinatorV2) {
    i_vrfCoodinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    i_gasLaneHashKey = gasLaneKeyHash;
    i_subscriptionId = subscriptionId;
    i_callbackGasLimit = callbackGasLimit;
    s_owner = msg.sender;
    s_tokenCounter = 0;
    s_dogTokensUri = dogTokensUri;
  }

  modifier onlyOwner() {
    require(s_owner == msg.sender, "Need to be a owner to request doggie");
    _;
  }

  // to mint a random doggie nft
  function requestDoggie() public onlyOwner returns (uint256 requestId) {
    requestId = i_vrfCoodinator.requestRandomWords(
      i_gasLaneHashKey,
      i_subscriptionId,
      REQUEST_CONFIRMATION,
      i_callbackGasLimit,
      NUM_WORDS
    );

    s_requestIdToSender[requestId] = msg.sender;
  }

  // callback function
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
    internal
    override
  {
    address dogOwner = s_requestIdToSender[requestId];
    // s_randomsWords = randomWords;
    uint256 tokenId = s_tokenCounter;
    s_tokenCounter = s_tokenCounter + 1;

    uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
    uint256 breed = getBreedWithModdedRng(moddedRng);

    //set the tokenURI
    _setTokenURI(tokenId, s_dogTokensUri[breed]);
  }

  function getChanceArray() public pure returns (uint256[3] memory) {
    return [10, 30, MAX_CHANCE_VALUE];
  }

  function getBreedWithModdedRng(uint256 moddedRng)
    public
    pure
    returns (uint256)
  {
    uint256 cummulativeSum = 0;
    uint256[3] memory chanceArray = getChanceArray();

    for (uint256 i = 0; i < chanceArray.length; i++) {
      if(moddedRng >= cummulativeSum && moddedRng < cummulativeSum + chanceArray[i])
        return i;
      
      cummulativeSum = cummulativeSum + chanceArray[i];
    }
  }
}
