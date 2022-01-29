// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;


/*

    A smart contract that functions as kickstarter: 
    
        1) Users can create project and ask for funding
        2) Users can fund projects they like
        3) If funding target is met, payment is made available

        ------

        Planned features: 
        
        1) 50% of payment is made available when funding target is met, 50% is made available after investors vote to release other 50%
        2) ERC20 support

*/



contract kickstarter {


    struct project {
        // address of deloyer
        address owner;
        // address of payee (can be owner)
        address payee;
        // funding target
        uint fundingTarget;
        // time of creation
        uint timeNow;
        // min 1 day max 60
        uint fundingTime;
        // project description
        string ipfsURL;
        // current funding amount
        uint funding;

    }

    struct investment {

        address projectOwner;

        uint projectID;

        uint amount;

    }

    // @dev owner address can list multiple projects
    mapping(address => mapping (uint => project)) public projects;

    // @dev user address can invest in multiple projects from multiple addresses
    mapping(address => mapping (address => mapping (uint => investment))) public investments;

    // @dev get number of listed services owner address
    mapping(address => uint[]) private listmappingOwner;

    // @dev ID of owner address project
    uint private ID;

    function createProject( 
        address payee, 
        uint fundingTarget, 
        uint fundingTime,
        string memory ipfsURL) 
        
        public {

        // @dev array of IDs of owner projects
        ID = listmappingOwner[msg.sender].length;


        projects[msg.sender][ID].owner = msg.sender;

        projects[msg.sender][ID].payee = payee;

        projects[msg.sender][ID].fundingTarget = fundingTarget;

        projects[msg.sender][ID].timeNow = block.timestamp;

        projects[msg.sender][ID].fundingTime = fundingTime;

        projects[msg.sender][ID].ipfsURL = ipfsURL;


        // @dev push .length to array
        listmappingOwner[msg.sender].push(ID);

        }


    function invest(address owner, uint ID) public payable {

        investments[msg.sender][owner][ID].projectOwner = owner;
        investments[msg.sender][owner][ID].projectID = ID;
        investments[msg.sender][owner][ID].amount = msg.value;
    
        projects[owner][ID].funding += msg.value; 

    }



    function withdraw(address owner, uint ID, uint amount) public {

        amount = investments[msg.sender][owner][ID].amount;

        require(amount > 0);

        investments[msg.sender][owner][ID].amount -= amount;

        projects[owner][ID].funding -= amount; 

        payable(msg.sender).transfer(amount);

    }


    function endFundingRound(address owner, uint ID) public {

        // @dev there may be a more efficient way of doing this
        uint t1;
        uint t2;
        uint timeNow;

        address payee;
        uint amount;

        t1 = projects[msg.sender][ID].timeNow;
        t2 = projects[msg.sender][ID].fundingTime;

        timeNow = block.timestamp;        

        require(timeNow >= t1 + t2);

        payee = projects[owner][ID].payee;

        amount = projects[owner][ID].funding;

        payable(payee).transfer(amount);

    }

}



