pragma solidity^0.5.5;
contract Locketh {
    address public owner;
    mapping(address=>User) public userProfile;
    mapping(address=>UserLoginId) public userLogin;
    mapping(uint=>address) public userList;
    mapping(address=>string) public matchAddrToEmail;
    mapping(address=>uint) public userRegisterStatus;
    mapping(string=>uint) public userEmailRegisterStatus;
    mapping(address=>uint) public userLoginStatus;
    mapping(address=>Events) public _events;
    mapping(address=>int) public stats;
    mapping(address=>mapping(string=>File)) public myLogins;
    mapping(address=>mapping(uint=>FileNum)) public myVault;
    mapping(address=>mapping(uint=>uint)) public myAccAvail;
    mapping(address=>string) public comments;
    uint public userCount;
    uint public startTime;
    uint public endTime;
    string public x;
    string public y;
  
    constructor() public {
        owner = msg.sender;
        userCount = 0;
    }
    modifier onlySignedInUser {
        require(userLoginStatus[msg.sender]==1);
        _;
    }
    struct User{
        address userEthAddress;
        string userEmail;
        string userPassword;
        string userName;
    }
    struct UserLoginId {
        string useremailid;
        string userpassword;
    }
    struct File {
        string fileApplicationName;
        string appUsername;
        string appPassword;
    }
    struct FileNum {
        uint filenum;
        string appUsername;
        string appPassword;
    }
    struct Events{
        uint event_startTime;
        uint event_endTime;
    }
    function signUpUser(string memory _uEmailId,string memory _uPass,string memory _uName) public {
        require(userRegisterStatus[msg.sender]==0);
        require(userEmailRegisterStatus[_uEmailId]==0);
        userProfile[msg.sender] = User(msg.sender,_uEmailId,_uPass,_uName);
        userLogin[msg.sender] = UserLoginId(_uEmailId,_uPass);
        matchAddrToEmail[msg.sender] = _uEmailId;
        userRegisterStatus[msg.sender] = 1;
        userEmailRegisterStatus[_uEmailId] = 1;
        userCount++;
        userList[userCount] = msg.sender;
    }
    function signInUser(string memory _uEmailId, string memory _uPass) public {
        require(keccak256(abi.encodePacked(matchAddrToEmail[msg.sender]))==keccak256(abi.encodePacked(_uEmailId)));
        require(keccak256(abi.encodePacked(userLogin[msg.sender].userpassword))==keccak256(abi.encodePacked(_uPass)));
        require(userLoginStatus[msg.sender]==0);
        require(_events[msg.sender].event_startTime==0);
        userLoginStatus[msg.sender] = 1;
        _events[msg.sender].event_startTime=block.timestamp;
        _events[msg.sender].event_endTime = _events[msg.sender].event_startTime + 240;
        getUserName();
        comments[msg.sender] = "Welcome";
    }
    function checkTime() public {
        if(_events[msg.sender].event_startTime!=0) {
            if(now>=_events[msg.sender].event_endTime) {
                comments[msg.sender] = "Timeout. Please Log in again";
                _events[msg.sender].event_startTime = 0;
                userLoginStatus[msg.sender] = 0;
                userProfile[msg.sender].userName = "Empty";
            } else if(now>_events[msg.sender].event_startTime) {
                comments[msg.sender] = "Account ON";
            }
        } else {
               comments[msg.sender] = "You are not logged in";
        }
    }
    
    function addGoogleAcc(string memory _appUsername,string memory _appPassword) public onlySignedInUser {
        checkTime();
        if(_events[msg.sender].event_startTime!=0) {
            myLogins[msg.sender]["google"] = File("google",_appUsername,_appPassword);
        } else {
            comments[msg.sender] = "Timeout Sign in again";
        }
    }
    function getGoogleAcc() public onlySignedInUser {
        checkTime();
        if(_events[msg.sender].event_startTime!=0) {
            x = myLogins[msg.sender]["google"].appUsername;
            y = myLogins[msg.sender]["google"].appPassword;
        } else{
            comments[msg.sender] = "Timeout Sign in again";
        }
    }
    function addAccount(uint num, string memory _appUsername,string memory _appPassword) public onlySignedInUser {
        checkTime();
        if(_events[msg.sender].event_startTime!=0) {
            myVault[msg.sender][num] = FileNum(num,_appUsername,_appPassword);
            myAccAvail[msg.sender][num] = 1;
            comments[msg.sender] = "Added";
        } else {
            comments[msg.sender] = "Timeout Sign in Again";
        }
    }
    function getAccount(uint _num) public onlySignedInUser {
        require(myAccAvail[msg.sender][_num]==1);
        checkTime();
        if(_events[msg.sender].event_startTime!=0) {
            x = myVault[msg.sender][_num].appUsername;
            y = myVault[msg.sender][_num].appPassword;
        } else {
            comments[msg.sender] = "Timeout Sign In Again";
        }
    }
    function getX() public view returns(string memory) {
        return x;
    }
    function getY() public view returns(string memory) {
        return y;
    }
    
    function timeout() public {
        _events[msg.sender].event_startTime=0;
        _events[msg.sender].event_endTime=0;
        userLoginStatus[msg.sender] = 0;
    }
    
    function getCurrentTime() public view returns(uint) {
        return now;
    }
    function getUsersCount() public view returns(uint) {
        return userCount;
    }
    function getUserAt(uint num) public view returns(address) {
        return userList[num];
    }
    function getUserName() public view returns(string memory) {
        return userProfile[msg.sender].userName;
    }
    
    function getComments() public view returns(string memory) {
        return comments[msg.sender];
    }
    function signOutUser() public onlySignedInUser {
        require(userLoginStatus[msg.sender]==1);
        require(_events[msg.sender].event_startTime!=0);
        _events[msg.sender].event_startTime = 0;
        stats[msg.sender] = 0;
        userLoginStatus[msg.sender] = 0;
        userProfile[msg.sender].userName = "Empty";
        comments[msg.sender] = "You are not logged in";
    }
}
