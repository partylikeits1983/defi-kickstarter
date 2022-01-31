// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Kickstarter {

    struct Project {
        // address of deloyer
        address owner;
        // address of payee (can be owner)
        address payee;
        // funding target
        uint fundingTarget;
        // time of creation
        uint timeNow; 
        // min 1 day max 60 from timeNow
        uint expiration;
        // project description
        string ipfsURL;
        // current funding amount
        uint funding;

    }

    struct Investment {
        // project owner
        address projectOwner;
        // project ID
        uint projectID;
        // amount to invest
        uint amount;

    }

    // @dev owner address can list multiple projects
    mapping(address => mapping (uint => Project)) public projects;

    // @dev user address can invest in multiple projects from multiple addresses
    mapping(address => mapping (address => mapping (uint => Investment))) public investments;

    // @dev get number of listed services owner address
    mapping(address => uint[]) private listmappingOwner;


    function createProject( 
        address payee, 
        uint fundingTarget, 
        uint fundingTime,
        string memory ipfsURL) 
        
        external {
        
        uint ID;

        // @dev array of IDs of owner projects
        ID = listmappingOwner[msg.sender].length;

        // @dev project funding expiration time
        uint expiration;

        expiration = block.timestamp + fundingTime;

        projects[msg.sender][ID].owner = msg.sender;
        projects[msg.sender][ID].payee = payee;
        projects[msg.sender][ID].fundingTarget = fundingTarget;
        projects[msg.sender][ID].timeNow = block.timestamp;
        projects[msg.sender][ID].expiration = expiration;
        projects[msg.sender][ID].ipfsURL = ipfsURL;

        // @dev push .length to array
        listmappingOwner[msg.sender].push(ID);

        }


    function invest(address owner, uint ID) external payable {

        require(block.timestamp <= projects[owner][ID].expiration);

        investments[msg.sender][owner][ID].projectOwner = owner;
        investments[msg.sender][owner][ID].projectID = ID;
        investments[msg.sender][owner][ID].amount = msg.value;

        projects[owner][ID].funding += msg.value; 

    }


    function withdraw(address owner, uint ID, uint amount) external {

        amount = investments[msg.sender][owner][ID].amount;

        require(amount > 0);

        investments[msg.sender][owner][ID].amount -= amount;

        projects[owner][ID].funding -= amount; 

        payable(msg.sender).transfer(amount);

    }


    // @dev anyone can call this function and end the funding round 
    function endFundingRound(address owner, uint ID) external {

        address payee;
        uint amount;

        uint timeNow;
        uint expiration;

        timeNow = block.timestamp; 
        expiration = projects[owner][ID].expiration;

        require(timeNow >= expiration);

        payee = projects[owner][ID].payee;

        amount = projects[owner][ID].funding;

        payable(payee).transfer(amount);

    }

}




