pragma solidity 0.5.0;


import "./Collateral.sol";
import "./SafeMath.sol";

// ----------------------------------------------------------------------------
// Collateral Auction Contract.
// 
// ----------------------------------------------------------------------------
contract Auction {
    using SafeMath for uint;

    address payable public tokenLoanContract;
    uint public lotNumber;
    uint public softClose;
    
    struct Bid {
      address payable bidder;
      uint value;
    }
    
    struct AuctionStruct {
        address tokenLot;
        uint expiryBlockHeight;
        Bid highestBid;
        Bid nextHighestBid;
    }

    mapping(uint => AuctionStruct) auctions;
    
    constructor(address payable _tokenLoanContract, uint _softClose) public {
        tokenLoanContract = _tokenLoanContract;
        softClose = _softClose;
    }

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
    }

    function createNewAuction(address _tokenLot, uint _expiryBlockHeight) onlyTokenLoan external {
        lotNumber = lotNumber.add(1);
        auctions[lotNumber] = AuctionStruct({tokenLot: _tokenLot, expiryBlockHeight: _expiryBlockHeight, highestBid: Bid({bidder: tokenLoanContract, value: 0}), nextHighestBid: Bid({bidder: tokenLoanContract, value: 0})});
    }
    
    function submitBid(uint _lotNumber) external payable {
        require(auctions[_lotNumber].expiryBlockHeight > block.number);
        if (msg.value > auctions[_lotNumber].highestBid.value) {
            auctions[_lotNumber].nextHighestBid = auctions[_lotNumber].highestBid;
            auctions[_lotNumber].highestBid = Bid({bidder: msg.sender, value: msg.value});
            if (auctions[_lotNumber].nextHighestBid.value > 0) {
                auctions[_lotNumber].nextHighestBid.bidder.transfer(auctions[_lotNumber].nextHighestBid.value);
            }
            
            // Extend auction if a new highest bid is received under ~3 minutes before auction closes.
            // This is called a "soft close" auction. It disincentivizes bidders from only bidding at the last second.
            
            if ((auctions[_lotNumber].expiryBlockHeight.sub(block.number)) < softClose) {
                auctions[_lotNumber].expiryBlockHeight = auctions[_lotNumber].expiryBlockHeight.add((softClose.sub(auctions[_lotNumber].expiryBlockHeight.sub(block.number))));
            }
        } else {
            msg.sender.transfer(msg.value);
        }
    }
    
    function twoHightestBidsDifference(uint _lotNumber) external view returns(uint) {
        if (auctions[_lotNumber].highestBid.value != 0) {
            return (auctions[_lotNumber].highestBid.value - auctions[_lotNumber].nextHighestBid.value);
        }
        return 0;
    }
    
    function winningBidder(uint _lotNumber) external view returns (address) {
        return auctions[_lotNumber].highestBid.bidder;
    }
    
    function tokenLot(uint _lotNumber) external view returns (address) {
        return auctions[_lotNumber].tokenLot;
    }

    function executePayment(uint _lotNumber) external {
        require(auctions[_lotNumber].expiryBlockHeight < block.number);
        tokenLoanContract.transfer(auctions[_lotNumber].highestBid.value);
        Collateral(auctions[_lotNumber].tokenLot).sendAuctionWinner(auctions[_lotNumber].highestBid.bidder);
        
        // Destroy auction
        auctions[_lotNumber].highestBid = Bid({bidder: tokenLoanContract, value: 0});
    }
    
}