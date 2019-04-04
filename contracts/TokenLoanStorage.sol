pragma solidity 0.5.6;

import "./SafeMath.sol";


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

}
