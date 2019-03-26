pragma solidity 0.5.6;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "Overflow detected.");
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "Underflow detected.");
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "Overflow detected.");
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "Can't divide by zero.");
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// TokenLoan (Logic) Contract.
// 
// ----------------------------------------------------------------------------
contract TokenLoan {
    using SafeMath for uint;

    address public owner;
    address payable public storageContract;
    TokenLoanStorage contractStorage;


    constructor (address payable _storageContract) public {
        owner = msg.sender;
        storageContract = _storageContract;
        contractStorage = TokenLoanStorage(storageContract);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    modifier OnlyCollateralContract {
        require(contractStorage.validCollateralContract(msg.sender), "You are not a valid Collateral Contract.");
        _;
    }

    function addToken (address _tokenAddress, string memory _tokenName) public onlyOwner {
        contractStorage.acceptedTokens.push(_tokenAddress);
        contractStorage.tokenNames[contractStorage.acceptedTokens.length.sub(1)] = _tokenName;
        bytes memory bytesName = bytes(_tokenName);
        bytes32 key = keccak256(bytesName);
        contractStorage.tokenIndexLookUp[key] = contractStorage.acceptedTokens.length.sub(1);
    } 

    function removeToken (uint _tokenIndex) public onlyOwner {
        contractStorage.removedTokens[_tokenIndex] = true;
    }

    function lookUpTokenIndex (string memory _tokenName) public view returns(uint) {
        bytes memory bytesName = bytes(_tokenName);
        bytes32 key = keccak256(bytesName);
        return contractStorage.tokenIndexLookUp[key];
    }

    function updateAllTotalTokenBalances () public {
        for (uint i = 0; i < contractStorage.acceptedTokens.length; i = i.add(1)) {
            if (!contractStorage.removedTokens[i]) {
                contractStorage.totalTokenBalances[i] = ERC20Interface(contractStorage.acceptedTokens[i]).balanceOf(address(this));
            }
        }
    }

    function updateUserBalances(uint _token, uint _balance, address _user) public OnlyCollateralContract {
        contractStorage.userTokenBalances[_token][_user] = _balance;
    }

    function sendStuckTokens (address _user, uint _token, uint _amount) public onlyOwner {
        ERC20Interface(contractStorage.acceptedTokens[_token]).transfer(_user, _amount);
    }
}


// ----------------------------------------------------------------------------
// TokenLoan (Storage) Contract.
// 
// ----------------------------------------------------------------------------
contract TokenLoanStorage {
    using SafeMath for uint;

    address public owner;
    address payable logicContract;
    address[] previousLogicContracts;
    uint loanID;

    struct Loan {
        address payable collateralOwner;
        address collateralAddress;
        uint loanType;
        uint loanAmount;
        uint[] tokens;
        mapping(uint => uint) tokenBalances;
    }

    address[] public acceptedTokens;
    address[] openCollateralContracts;
    mapping(address => bool) public validCollateralContract;
    mapping(uint => bool) removedTokens;
    mapping(uint => string) tokenNames;
    mapping(bytes32 => uint) tokenIndexLookUp;
    mapping(uint => mapping(address => uint)) userTokenBalances;
    mapping(uint => uint) totalTokenBalances;

    constructor (address payable _logicContract) public {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    modifier OnlyLogicContract {
        require(msg.sender == logicContract, "You are not a valid TokenLoan logic contract.");
        _;
    }

    function updateLogic (address payable _logicContract) public onlyOwner {
        previousLogicContracts.push(logicContract);
        logicContract = _logicContract;
    }
}




// ----------------------------------------------------------------------------
// Collateral Contract.
// 
// ----------------------------------------------------------------------------
contract Collateral {
    using SafeMath for uint;

    address payable user;
    address tokenLoanContract;
    uint[] expectedTokens;

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
    }


    constructor (uint[] memory _tokens, address payable _user, address _tokenLoanContract) public {
        user = _user;
        tokenLoanContract = _tokenLoanContract;
        for (uint i = 0; i < _tokens.length; i = i.add(1)) {
            expectedTokens.push(_tokens[i]);
        }
    }

    function updateUserBalance() public {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            TokenLoan(tokenLoanContract).updateUserBalances(expectedTokens[i], 
                ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this)), 
                user);
        }
    }

    function sendBack() public onlyTokenLoan {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            uint balance = ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).transfer(user, balance);
            }
        }
    }

    function sendAuctionWinner(address _winner) public onlyTokenLoan {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            uint balance = ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).transfer(_winner, balance);
            }
        }
    }
}



// ----------------------------------------------------------------------------
// Collateral Auction Contract.
// 
// ----------------------------------------------------------------------------
contract Auction {
    using SafeMath for uint;

    address payable tokenLoanContract;
    uint lotNumber;
    uint softClose;
    
    struct Bid {
      address payable bidder;
      uint value;
    }
    
    struct AuctionStruct {
        address tokenLot;
        uint expiryBlockHeight;
        Bid highestBid;
        Bid nextHighestBid;
    }

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
    }
    
    mapping(uint => AuctionStruct) auctions;
    
    constructor(address payable _tokenLoanContract, uint _softClose) public {
        tokenLoanContract = _tokenLoanContract;
        softClose = _softClose;
    }

    function createNewAuction(address _tokenLot, uint _expiryBlockHeight) onlyTokenLoan external {
        lotNumber = lotNumber.add(1);
        auctions[lotNumber] = AuctionStruct({tokenLot: _tokenLot, expiryBlockHeight: _expiryBlockHeight, highestBid: Bid({bidder: tokenLoanContract, value: 0}), nextHighestBid: Bid({bidder: tokenLoanContract, value: 0})});
    }
    
    function submitBid(uint _lotNumber) external payable {
        require(auctions[_lotNumber].expiryBlockHeight > block.number);
        if (msg.value > auctions[_lotNumber].highestBid.value) {
            auctions[_lotNumber].nextHighestBid = auctions[_lotNumber].highestBid;
            auctions[_lotNumber].highestBid = Bid({bidder: msg.sender, value: msg.value});
            auctions[_lotNumber].nextHighestBid.bidder.transfer(auctions[_lotNumber].nextHighestBid.value);
            
            // Extend auction if a new highest bid is received under ~3 minutes before auction closes.
            // This is called a "soft close" auction. It disincentivizes bidders from only bidding at the last second.
            
            if ((auctions[_lotNumber].expiryBlockHeight.sub(block.number)) < softClose) {
                auctions[_lotNumber].expiryBlockHeight = auctions[_lotNumber].expiryBlockHeight.add((softClose.sub(auctions[_lotNumber].expiryBlockHeight.sub(block.number))));
            }
        } else {
            msg.sender.transfer(msg.value);
        }
    }
    
    function twoHightestBidsDifference(uint _lotNumber) public view returns(uint) {
        if (auctions[_lotNumber].highestBid.value != 0) {
            return (auctions[_lotNumber].highestBid.value - auctions[_lotNumber].nextHighestBid.value);
        }
        return 0;
    }
    
    function winningBidder(uint _lotNumber) public view returns (address) {
        return auctions[_lotNumber].highestBid.bidder;
    }

    function executePayment(uint _lotNumber) onlyTokenLoan external {
        require(auctions[_lotNumber].expiryBlockHeight < block.number);
        tokenLoanContract.transfer(auctions[_lotNumber].highestBid.value);
        
        // Destroy auction
        auctions[_lotNumber].highestBid = Bid({bidder: tokenLoanContract, value: 0});
    }
    
}

