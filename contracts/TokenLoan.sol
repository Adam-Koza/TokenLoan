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
    address public auctionContract;
    TokenLoanStorage contractStorage;
    Auction auction;


    constructor (address payable _storageContract, address _auctionContract) public {
        owner = msg.sender;
        storageContract = _storageContract;
        contractStorage = TokenLoanStorage(storageContract);
        auctionContract = _auctionContract;
        auction = Auction(auctionContract);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    modifier OnlyCollateralContract {
        require(contractStorage.validCollateralContract(msg.sender), "You are not a valid Collateral Contract.");
        _;
    }

    function lookUpTokenIndex (string calldata _tokenName) external view returns (uint) {
        bytes memory bytesName = bytes(_tokenName);
        bytes32 key = keccak256(bytesName);
        return contractStorage.tokenIndexLookUp(key);
    }

    function createCollateralContract (uint[] calldata _tokens) external returns (address) {
        Collateral newCollateralContract = new Collateral(_tokens, msg.sender, address(this), storageContract);
        contractStorage.incrementLoanID();
        contractStorage.updateLoan(contractStorage.loanID(), msg.sender, address(newCollateralContract), true, 0, 0, _tokens);
        contractStorage.setValidCollateralContract(address(newCollateralContract), true);
        contractStorage.updateLoanIndexLookUp(address(newCollateralContract), contractStorage.loanID());
        return address(newCollateralContract);
    }

    function updateUserBalances(uint _token, uint _balance) external OnlyCollateralContract {
        contractStorage.updateLoanTokenBalance(contractStorage.loanIndexLookUp(msg.sender), _token, _balance);
    }

    function closeAuction (uint _lotNumber) external {
        
        address lotWinner = auction.winningBidder(_lotNumber);
        address collateral = auction.tokenLot(_lotNumber);
        auction.executePayment(_lotNumber);
        Collateral(collateral).sendAuctionWinner(lotWinner);
    }

    function startAuction(uint _loanID) internal {
        auction.createNewAuction(contractStorage.loanCollateralAddress(_loanID), block.number + 60);
        contractStorage.updateLoan(
            _loanID,
            contractStorage.loanCollateralOwner(_loanID),
            contractStorage.loanCollateralAddress(_loanID),
            false,
            contractStorage.loanType(_loanID),
            contractStorage.loanAmount(_loanID),
            contractStorage.loanTokens(_loanID)
        );
    }

    // Dummy function, replace with an oracle. 
    function checkLoan (uint _loanID) external {
        // Query oracle. Assume loan is bad.
        startAuction(_loanID);
    }


    function sendStuckTokens (address _user, uint _token, uint _amount) external onlyOwner {
        ERC20Interface(contractStorage.acceptedTokens(_token)).transfer(_user, _amount);
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
    address[] public previousLogicContracts;
    uint public loanID;

    struct Loan {
        address payable collateralOwner;
        address collateralAddress;
        bool open;
        uint loanType;
        uint loanAmount;
        uint[] tokens;
        mapping(uint => uint) tokenBalances;
    }

    address[] public acceptedTokens;
    mapping(uint => bool) public removedTokens;
    mapping(uint => string) public tokenNames;
    mapping(bytes32 => uint) public tokenIndexLookUp;
    mapping(uint => uint) public totalTokenBalances;
    mapping(address => bool) public validCollateralContract;
    mapping(uint => Loan) public loans;
    mapping(address => uint) public loanIndexLookUp;

    // Additional Mappings if required in the future:
    mapping(bytes32 => bytes) public ownerMapping;
    mapping(bytes32 => bytes) public logicMapping;
    mapping(bytes32 => bytes) public collateralMapping;


    constructor (address payable _logicContract) public {
        owner = msg.sender;
        logicContract = _logicContract;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    modifier onlyLogicContract {
        require(msg.sender == logicContract, "You are not a valid TokenLoan logic contract.");
        _;
    }

    modifier onlyCollateralContract {
        require(validCollateralContract[msg.sender], "You are not a valid Collateral contract.");
        _;
    }

    function updateLogicContract (address payable _logicContract) external onlyOwner {
        previousLogicContracts.push(logicContract);
        logicContract = _logicContract;
    }

    function addToken (address _tokenAddress, string calldata _tokenName) external onlyOwner {
        acceptedTokens.push(_tokenAddress);
        tokenNames[acceptedTokens.length.sub(1)] = _tokenName;
        bytes memory bytesName = bytes(_tokenName);
        bytes32 key = keccak256(bytesName);
        tokenIndexLookUp[key] = acceptedTokens.length.sub(1);
    } 

    function removeToken (uint _tokenIndex) external onlyOwner {
        removedTokens[_tokenIndex] = true;
    }

    function setTokenName (uint _token, string calldata _name) external onlyOwner {
        tokenNames[_token] = _name;
        bytes memory bytesName = bytes(_name);
        bytes32 key = keccak256(bytesName);
        tokenIndexLookUp[key] = _token;
    }

    function incrementLoanID() external onlyLogicContract {
        loanID = loanID.add(1);
    }

    function setValidCollateralContract (address _collateralContract, bool _value) external onlyLogicContract {
        validCollateralContract[_collateralContract] = _value;
    }

    function updateLoanTokenBalance(uint _loanID, uint _token, uint _balance) external onlyLogicContract {
        loans[_loanID].tokenBalances[_token] = _balance;
    }

    function updateLoan(uint _loanID, address payable _collateralOwner, address _collateralAddress, bool _open, uint _loanType, uint _loanAmount, uint[] calldata _tokens) external onlyLogicContract {
        loans[_loanID].collateralOwner = _collateralOwner;
        loans[_loanID].collateralAddress = _collateralAddress;
        loans[_loanID].open = _open;
        loans[_loanID].loanType = _loanType;
        loans[_loanID].loanAmount = _loanAmount;
        loans[_loanID].tokens = _tokens;
    }

    function updateTotalTokenBalances (uint _token, uint _balance) external onlyLogicContract {
        totalTokenBalances[_token] = _balance;
    }
    
    function updateLoanIndexLookUp (address _address, uint _loanID) external onlyLogicContract {
        loanIndexLookUp[_address] = _loanID;
    }

    // Setters for future mappings if required:
    function updateOwnerMapping (bytes32 _key, bytes calldata _value) external onlyOwner {
        ownerMapping[_key] = _value;
    }

    function updateLogicMapping (bytes32 _key, bytes calldata _value) external onlyLogicContract {
        logicMapping[_key] = _value;
    }

    function updateCollateralMapping (bytes32 _key, bytes calldata _value) external onlyCollateralContract {
        collateralMapping[_key] = _value;
    }
    
    function loanCollateralAddress(uint _loanID) external view returns (address) {
        return loans[_loanID].collateralAddress;
    }
    
    function loanCollateralOwner(uint _loanID) external view returns (address payable) {
        return loans[_loanID].collateralOwner;
    }
    
    function loanOpen(uint _loanID) external view returns (bool) {
        return loans[_loanID].open;
    }
    
    function loanType(uint _loanID) external view returns (uint) {
        return loans[_loanID].loanType;
    }
    
    function loanAmount(uint _loanID) external view returns (uint) {
        return loans[_loanID].loanAmount;
    }
    
    function loanTokens(uint _loanID) external view returns (uint[] memory) {
        return loans[_loanID].tokens;
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
    address storageContract;
    uint[] expectedTokens;

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
    }


    constructor (uint[] memory _tokens, address payable _user, address _tokenLoanContract, address _storageContract) public {
        user = _user;
        tokenLoanContract = _tokenLoanContract;
        storageContract = _storageContract;
        for (uint i = 0; i < _tokens.length; i = i.add(1)) {
            expectedTokens.push(_tokens[i]);
        }
    }

    function updateUserBalance() external {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            TokenLoan(tokenLoanContract).updateUserBalances(expectedTokens[i], 
                ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this)));
        }
    }

    function sendBack() external onlyTokenLoan {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            uint balance = ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).transfer(user, balance);
            }
        }
    }

    function sendAuctionWinner(address _winner) external onlyTokenLoan {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            uint balance = ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).transfer(_winner, balance);
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

    mapping(uint => AuctionStruct) auctions;
    
    constructor(address payable _tokenLoanContract, uint _softClose) public {
        tokenLoanContract = _tokenLoanContract;
        softClose = _softClose;
    }

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
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
    
    function twoHightestBidsDifference(uint _lotNumber) external view returns(uint) {
        if (auctions[_lotNumber].highestBid.value != 0) {
            return (auctions[_lotNumber].highestBid.value - auctions[_lotNumber].nextHighestBid.value);
        }
        return 0;
    }
    
    function winningBidder(uint _lotNumber) external view returns (address) {
        return auctions[_lotNumber].highestBid.bidder;
    }
    
    function tokenLot(uint _lotNumber) external view returns (address) {
        return auctions[_lotNumber].tokenLot;
    }

    function executePayment(uint _lotNumber) onlyTokenLoan external {
        require(auctions[_lotNumber].expiryBlockHeight < block.number);
        tokenLoanContract.transfer(auctions[_lotNumber].highestBid.value);
        
        // Destroy auction
        auctions[_lotNumber].highestBid = Bid({bidder: tokenLoanContract, value: 0});
    }
    
}

