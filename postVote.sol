pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

interface Membership {
    struct MemberDetail {
        uint id;
        bool MemberPaid;
        bool MemberKYC;
        bool Certifier;
        bool Champion;
        string[] Values;
        string Entity;
        uint VotingPoints;
    }

    function isMember(address user) external view returns(bool);
    
    function getVotingPoints(address user) external view returns(uint);
    
    function info(address _add) external view returns(MemberDetail memory);
    
    function subVotingPoints(address _add, uint _val) external;
    
}

contract Voting { 
    
    struct Post {
        address user;
        uint parent;
        string value;
        uint upvote;
        uint timestamp;
        uint downvote;
        uint votingMechanism;
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
        uint votingMechanism;
        uint hasUpvoted;
        uint hasDownvoted;
    }
    
    uint256 id = 0;
    
    
    mapping(uint => Post) public posts;
    mapping(uint => mapping(address => member)) public memberVote;
    
    uint256[] allIDs;
    uint256[] postIDs;
    uint256[] commentIDs;
    
    Membership mem;
    
    address admin;
    
    constructor(Membership _address) public {
        admin = msg.sender;
        mem = _address;
    }

    modifier onlyOwner() {
        require(msg.sender == admin,"You are not an admin");
        _;
    }

    
    modifier arkMember(address user) {
        require(mem.isMember(user),"You are not a member");
        _;
    }
    
    modifier arkVoter(address user) {
        
        require(mem.info(user).MemberPaid,"You are not Paid");
        require(mem.info(user).MemberKYC,"You are not verified");
        _;
    }
    
    function getPost(uint _id) public view arkMember(msg.sender) returns(returnPost memory) {
        returnPost memory rpst = returnPost(posts[_id].user, posts[_id].value, posts[_id].upvote, posts[_id].parent, posts[_id].timestamp, posts[_id].downvote, posts[_id].votingMechanism, memberVote[id][msg.sender].upvotes, memberVote[_id][msg.sender].downvotes);
        return rpst;
    } 
    
    function totalPost() public view returns(uint256[] memory) {
        return allIDs;
    }
    
    function totalCmnt() public view returns(uint256[] memory) {
        return commentIDs;
    }
    
    function allPosts() public view returns(uint[] memory) {
        return postIDs;
    }

    function addPost(string memory _value, uint votingMechanism) public arkVoter(msg.sender) returns(uint) {
        id += 1;
        posts[id].user = msg.sender;
        posts[id].value = _value;
        posts[id].timestamp = now;
        posts[id].votingMechanism = votingMechanism;
        postIDs.push(id);
        allIDs.push(id);
        return id;
    }
    
    function statusOwner(uint _id) public view returns(address) {
        require(posts[_id].user!=address(0),"Invalid id");
        return posts[_id].user;
    }
    
    function deletePost(uint _id) public {
        require(posts[_id].user == msg.sender,"You are an Imposter");
            posts[_id].user = address(0);
            posts[_id].value = "";
            posts[_id].upvote = 0;
            posts[_id].downvote = 0;
            posts[_id].parent = 0;
            posts[_id].timestamp = 0;
            posts[_id].votingMechanism = 0;
        
    }
    
    function postComment( uint _parent, string memory _value) public arkMember(msg.sender) {
        id += 1;
        posts[id].user = msg.sender;
        posts[id].parent = _parent;
        posts[id].value = _value; 
        posts[id].upvote = 0;
        posts[id].downvote = 0;
        posts[id].timestamp = now;
        commentIDs.push(id);
        postIDs.push(id);
    }
    
    function totalPoints(address user) public view returns(uint) {
        return mem.info(user).VotingPoints;
    }
    
    function totalUpvote(address user, uint _id) public arkVoter(user) view returns(uint) {
            return posts[_id].upvote;
    }

    function totalDownvote(address user, uint _id) public arkVoter(user) view returns(uint) {
            return posts[_id].downvote;
    }    
    
    function message(address user, uint _id) public arkMember(user) view returns(string memory) {
            return posts[_id].value;
    }
    
    function totalVote(address user, uint _id) public arkVoter(user) view returns(int) {
            return (int(posts[_id].upvote) - int(posts[_id].downvote));
    }

    function upvote(uint _id, uint vote) public arkVoter(msg.sender) {
        address user = msg.sender;
        require(memberVote[_id][user].downvotes == 0 && memberVote[_id][user].upvotes == 0,"Already Voted");
        uint votingMechanism = posts[_id].votingMechanism;
        if(votingMechanism == 1){
            upvoteQuadratic(user, _id, vote);
        }
    }
    

    function upvoteQuadratic(address user, uint _id, uint vote) internal {
            
        uint point = vote * vote;
        uint balance = mem.getVotingPoints(user);
        
        if (point >= balance) {
            revert("Not enough points");
        }
        
        memberVote[_id][user].upvotes = vote;
       
        
        mem.subVotingPoints(user, point);
        
        posts[_id].upvote += vote;
    }
    
    function Downvote(address user, uint _id, uint vote) public arkVoter(user) {
        
        require(memberVote[_id][user].downvotes == 0 && memberVote[_id][user].upvotes == 0,"Already Voted");
            
        uint point = vote * vote;
        uint balance = mem.getVotingPoints(user);
        
        if (point > balance) {
            revert("Not enough points");
        }
        
        memberVote[_id][user].downvotes = vote;
        balance = balance - point;
        
        mem.subVotingPoints(user, balance);
        
        posts[_id].downvote += vote;
    }
}