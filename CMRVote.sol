// contracts/CMRVote.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CMRVote is ERC721,Ownable {

    constructor() ERC721("CMR Vote Token","VOTE") 
    {}
    using Counters for Counters.Counter;
    Counters.Counter private _VoteTokenIds;

    struct Vote {
        uint256 id;
        address creator;
        string voteType;
        string subject;
        string description;
        string[] choices;
        uint256[] counts;
        uint256 start;
        uint256 end;
        address[] voter;
        string uri;
    }

    Vote[] public votes;

    event NewVote(address indexed owner, uint256 voteId, string uri);

    function createVote(string memory _voteType,string memory _subject,string memory _description,string[] memory _choices,uint256[] memory _counts,uint256 _start,uint256 _end,string memory uri) public {
        string[] memory choices = _choices; 
        uint256[] memory counts = _counts; 
         
        address[] memory voterAddress; 
        uint256 voteId = _VoteTokenIds.current();
        Vote memory newVote = Vote(voteId,msg.sender,_voteType,_subject,_description,choices,counts,_start,_end,voterAddress,uri);
        votes.push(newVote); 
        _safeMint(msg.sender,voteId);
        emit NewVote(msg.sender,voteId,uri);
        _VoteTokenIds.increment();
    }
    
    //get all
    function getVotes() public view returns(Vote[] memory)
    {
        return votes;
    } 
    //get vote by id
    function getVoteById(uint256 _voteId) public view returns(Vote memory)
    {
        require(_exists(_voteId), "Ce vote n'existe pas");
        Vote storage thisVote = votes[_voteId];
        return thisVote;
    }
    //get my created
    function getOwnedVotes() public view returns(Vote[] memory)
    {
        Vote[] memory myVotes = new Vote[](balanceOf(msg.sender));
        uint256 counter = 0;
        for(uint256 i = 0; i < votes.length; i++){
            if(ownerOf(i) == msg.sender){
                myVotes[counter] = votes[i];
                counter++;
            }
        } 
        return myVotes;
    }

    //get vote address in counts
    function _canVote(uint256 _voteId,address _voter) internal view returns(bool)
    {
        require(_exists(_voteId), "Ce vote n'existe pas");
        bool myVotes = true;  
            if(votes[_voteId].voter.length > 0){
                for(uint256 j = 0; j < votes[_voteId].voter.length; j++){
                    if(votes[_voteId].voter[j] == _voter)
                    myVotes = false; 
                } 
            } 
        return myVotes;
    }
 
    //vote
    function vote(uint256 _voteId,uint256 _choiceKey) public 
    {
        require(_canVote(_voteId,msg.sender),"Vous avez deja votez"); 
        
        Vote storage thisVote = votes[_voteId];
        require(block.timestamp > thisVote.start,"Les votes ne sont pas ouvert");
        require(block.timestamp < thisVote.end,"Les votes sont clos");
        require(_exists(thisVote.counts[_choiceKey]), "Ce choix n'existe pas");
        thisVote.counts[_choiceKey]++;  
        thisVote.voter.push(msg.sender);
    }
}