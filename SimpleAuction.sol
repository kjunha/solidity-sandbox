pragma solidity ^0.4.24;
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
    
    function auctionEnded() public {
        require(now >= auctionEnd);
        require(!ended);
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}