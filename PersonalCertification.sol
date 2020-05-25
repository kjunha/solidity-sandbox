pragma solidity ^0.4.24;
contract PersonalCertification {
    address admin;
    struct AppDetail {
        bool allowReference;
        uint approveBlockNo;
        uint refLimitBlockNo;
        address applicant;
    }
    
    struct PersonDetail {
        string name;
        string birth;
        address[] orglist;
    }
    
    struct OrganizationDetail {
        string name;
    }
    
    mapping(address => AppDetail) appDetail;
    mapping(address => PersonDetail) personDetail;
    mapping(address => OrganizationDetail) public orgDetail;
    
    constructor() public {
        admin = msg.sender;
    }
    
    //본인정보 등록
    function setPerson(string _name, string _birth) public {
        personDetail[msg.sender].name = _name;
        personDetail[msg.sender].birth = _birth;
    }
    
    //조직정보 등록
    function setOrganization(string _name) public {
        orgDetail[msg.sender].name = _name;
    }
    
    //조직이 개인의 소속을 증명
    
    function setBelong(address _person) public {
        personDetail[_person].orglist.push(msg.sender);
    }
    
    //본인 확인정보 참조 허가
    function setApprove(address _applicant, uint _span) public {
        appDetail[msg.sender].allowReference = true;
        appDetail[msg.sender].approveBlockNo = block.number;
        appDetail[msg.sender].refLimitBlockNo = block.number + _span;
        appDetail[msg.sender].applicant = _applicant;
    }

    //본인확인정보 확인
    function getPerson(address _person) public view returns(
        bool _allowReference,
        uint _approveBlockNo,
        uint _refLimitBlockNo,
        address _applicant,
        string _name,
        string _birth,
        address[] _orglist
        ) {
            _allowReference = appDetail[_person].allowReference;
            _approveBlockNo = appDetail[_person].approveBlockNo;
            _refLimitBlockNo = appDetail[_person].refLimitBlockNo;
            _applicant = appDetail[_person].applicant;
            if(((msg.sender == _applicant)&&(_allowReference == true)&&(block.number < _refLimitBlockNo))||(msg.sender == admin)||(msg.sender == _person)) {
                _name = personDetail[_person].name;
                _birth = personDetail[_person].birth;
                _orglist = personDetail[_person].orglist;
            }
        }
}

/*
0번 Admin
1번 인증기관 "conpany"
2번 열람자 
3번 정보 공개자 "me"
4번
*/