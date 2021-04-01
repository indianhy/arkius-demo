pragma solidity 0.5.7;
pragma experimental ABIEncoderV2;

interface membership {
    
    function isMember(address user) external view returns(bool);
    
    function paymentGetter(address user) external view returns(bool);
    
    function kycGetter(address user) external view returns(bool);
    
    function pointsGetter(address _add) external view returns(uint);
    
    function pointsSetter(address _add, uint _val) external;
    
}

contract ballot { 
    
    struct post {
        address user;
        uint parent;
        string value;
        uint upvote;
        uint timestamp;
        uint downvote;
    }
    
    struct member {
        uint upvotes;
        uint downvotes;
    }
    
    struct returnPost {
        address user;
        string value;
        uint upvote;
        uint parent;
        uint timestamp;
        uint downvote;
        uint hasUpvoted;
        uint hasDownvoted;
    }
    
    uint256 id = 0;
    
    
    mapping(uint => post) public pst;
    mapping(uint => mapping(address => member)) public memVote;
    
    uint256[] posts;
    uint256[] totalpost;
    uint256[] totalcmnt;
    
    membership mem;
    
    constructor(membership _address) public {
        mem = _address;
    }
    
    modifier arkMember(address user) {
        require(mem.isMember(user),"You are not a member");
        _;
    }
    
    modifier arkVoter(address user) {
        require(mem.paymentGetter(user),"You are not Paid");
        require(mem.kycGetter(user),"You are not verified");
        _;
    }
    
    function getPost(uint id, address _add) public view returns(returnPost memory) {
        returnPost memory rpst = returnPost(pst[id].user, pst[id].value, pst[id].upvote, pst[id].parent, pst[id].timestamp, pst[id].downvote, memVote[id][_add].upvotes, memVote[id][_add].downvotes);
        return rpst;
    } 
    
    function totalPost() public view returns(uint256[] memory) {
        return totalpost;
    }
    
    function totalCmnt() public view returns(uint256[] memory) {
        return totalcmnt;
    }
    
    function allPost() public view returns(uint[] memory) {
        return posts;
    }
    
    function postStatus(address user, string memory _value) public arkMember(user) returns(uint) {
        id += 1;
        pst[id].user = user;
        pst[id].value = _value;
        pst[id].upvote = 0;
        pst[id].parent = 0;
        pst[id].downvote = 0;
        pst[id].timestamp = now;
        posts.push(id);
        totalpost.push(id);
        return id;
    }
    
    function statusOwner(uint _id) public view returns(address) {
        if (keccak256(bytes(pst[_id].value)) != keccak256(bytes(""))) {
            return pst[_id].user;
        }
        else {
            revert("Invalid Input");
        }
    }
    
    function deletePost(uint _id, address _add) public {
        require(pst[_id].user == _add,"You are an Imposter");
        if (keccak256(bytes(pst[_id].value)) != keccak256(bytes(""))) {
            pst[_id].user = address(0);
            pst[_id].value = "";
            pst[_id].upvote = 0;
            pst[_id].downvote = 0;
            pst[_id].parent = 0;
            pst[_id].timestamp = 0;
        }
    }
    
    function postComment(address user, uint _parent, string memory _value) public arkMember(user) {
        id += 1;
        pst[id].user = user;
        pst[id].parent = _parent;
        pst[id].value = _value; 
        pst[id].upvote = 0;
        pst[id].downvote = 0;
        pst[id].timestamp = now;
        totalcmnt.push(id);
        posts.push(id);
    }
    
    function totalPoints(address user) public view returns(uint) {
        return mem.pointsGetter(user);
    }
    
    function totalUpvote(address user, uint _id) public arkVoter(user) view returns(uint) {
            return pst[_id].upvote;
    }

    function totalDownvote(address user, uint _id) public arkVoter(user) view returns(uint) {
            return pst[_id].downvote;
    }    
    
    function message(address user, uint _id) public arkMember(user) view returns(string memory) {
            return pst[_id].value;
    }
    
    function totalVote(address user, uint _id) public arkVoter(user) view returns(int) {
            return (int(pst[_id].upvote) - int(pst[_id].downvote));
    }
    
    // function Upvote(address user, uint _id) public arkVoter(user) {
    //     if (memVote[_id][user].downvotes == 0) {
            
    //         uint point = memVote[_id][user].upvotes;
    //         uint balance = mem.pointsGetter(user);
            
    //         point = (2 * point) + 1;
    //         if (point > balance) {
    //             revert("Not enough points");
    //         }
            
    //         memVote[_id][user].upvotes += 1;
    //         balance = balance - point;
            
    //         mem.pointsSetter(user, balance);
            
    //         pst[_id].upvote += 1;
    //     }
    //     else {
            
    //         memVote[_id][user].downvotes -= 1;
            
    //         uint point = memVote[_id][user].downvotes;
    //         uint balance = mem.pointsGetter(user) + (2*point) + 1;

    //         mem.pointsSetter(user, balance);
            
    //         pst[_id].upvote += 1;
    //         pst[_id].downvote -= 1;
    //     }
    // }
    
    // function Downvote(address user, uint _id) public arkVoter(user) {
    //     if (memVote[_id][user].upvotes == 0) {
            
    //         uint point = memVote[_id][user].downvotes;
    //         uint balance = mem.pointsGetter(user);
            
    //         point = (2 * point) + 1;
    //         if (point > balance) {
    //             revert("Not enough points");
    //         }
            
    //         memVote[_id][user].downvotes += 1;
    //         balance = balance - point;
            
    //         mem.pointsSetter(user, balance);
            
    //         pst[_id].downvote += 1;
    //     }
    //     else {
            
    //         memVote[_id][user].upvotes -= 1;
            
    //         uint point = memVote[_id][user].upvotes;
    //         uint balance = mem.pointsGetter(user) + (2*point) + 1;

    //         mem.pointsSetter(user, balance);
            
    //         pst[_id].upvote -= 1;
    //         pst[_id].downvote += 1;
    //     }
    // }
    
    function Upvote(address user, uint _id, uint vote) public arkVoter(user) {
        
        require(memVote[_id][user].downvotes == 0 && memVote[_id][user].upvotes == 0,"Already Voted");
            
        uint point = vote * vote;
        uint balance = mem.pointsGetter(user);
        
        if (point > balance) {
            revert("Not enough points");
        }
        
        memVote[_id][user].upvotes = vote;
        balance = balance - point;
        
        mem.pointsSetter(user, balance);
        
        pst[_id].upvote += 1;
    }
    
    function Downvote(address user, uint _id, uint vote) public arkVoter(user) {
        
        require(memVote[_id][user].downvotes == 0 && memVote[_id][user].upvotes == 0,"Already Voted");
            
        uint point = vote * vote;
        uint balance = mem.pointsGetter(user);
        
        if (point > balance) {
            revert("Not enough points");
        }
        
        memVote[_id][user].downvotes = vote;
        balance = balance - point;
        
        mem.pointsSetter(user, balance);
        
        pst[_id].downvote += 1;
    }
}