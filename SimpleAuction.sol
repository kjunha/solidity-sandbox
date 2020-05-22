pragma solidity ^0.4.24;
/*
    An Auctionier can hold an Auction.
    The Auctionier can select beneficiary and time limit
    
    A Smart Contract that auctionier can have control to start and end the aution can be considered.

*/
contract SimpleAuction {
    //Auction information
    address public beneficiary;
    uint public auctionEnd;
    
    //Current Bid status
    address public highestBidder;
    uint public highestBid;
    
    mapping(address => uint) pendingReturns;
    bool ended;
    
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    constructor(uint _biddingTime, address _beneficiary) public {
        beneficiary = _beneficiary;
        auctionEnd = now + _biddingTime;
    }
    
    function bid() public payable {
        require(now <= auctionEnd);
        require(msg.value > highestBid);
        if(highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }
    
    //A transaction for message sender should only happen in one function.
    //For example, it is not a good idea to revert money back to the previous highest bidder
    //when new highest bid is reveived. Instead, when new highest bid is accepted, the previous bid is
    //pended for previous bidder to revert back. (withdraw)

    function withdraw() public returns(bool) {
        uint amount = pendingReturns[msg.sender];
        if(amount > 0) {
            pendingReturns[msg.sender] = 0;
            if(!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                revert();
                return false;
            }
        }
        return true;
    }
    
    //Future update: all pended amount is reverted when the auction is closed.
    function auctionEnded() public {
        require(now >= auctionEnd);
        require(!ended);
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}