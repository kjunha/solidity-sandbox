pragma solidity ^0.4.24;
contract RandomGen {
    
    //Timestamp 가 예측가능함으로, 좋은 난수 생성이라고 볼 수 없음
    // function get(uint max) public view returns(uint, uint) {
    //     uint block_timestamp = block.timestamp;
    //     uint mod = block_timestamp % max + 1;
    //     return(block_timestamp, mod);
    // }
    
    address owner;
    uint numberMax;
    struct draw {
        uint blockNumber;
        uint drawnNumber;
    }
    
    struct draws {
        uint numDraws;
        mapping (uint => draw) draws;
    }
    
    mapping(address => draws) requests;
    
    event ReturnNextIndex(uint _index);
    event ReturnDraw(int _status, bytes32 _blockhash, uint _drawNumber);
    
    constructor(uint _max) public{
        owner = msg.sender;
        numberMax = _max;
    }
    
    function request() public returns(uint) {
        uint _nextIndex = requests[msg.sender].numDraws;
        requests[msg.sender].draws[_nextIndex].blockNumber = block.number;
        requests[msg.sender].numDraws = _nextIndex + 1;
        emit ReturnNextIndex(_nextIndex);
        return _nextIndex;
    }
    
    function get(uint _index) public returns(int status, bytes32 hash, uint drawNumber) {
        if(_index >= requests[msg.sender].numDraws) {
            emit ReturnDraw(-2,0,0);
            return(-2,0,0);
        } else {
            uint _nextBlockNumber = requests[msg.sender].draws[_index].blockNumber + 1;
            if(_nextBlockNumber >= block.number) {
                emit ReturnDraw(-1,0,0);
                return(-1,0,0);
            } else {
                bytes32 _blockhash = block.blockhash(_nextBlockNumber);
                uint _drawNumber = uint (_blockhash) % numberMax + 1;
                requests[msg.sender].draws[_index].drawnNumber = _drawNumber;
                emit ReturnDraw(0, _blockhash, _drawNumber);
                return (0, _blockhash, _drawNumber);
                
            }
        }
    }
    
}