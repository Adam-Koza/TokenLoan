pragma solidity 0.6.0;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, "");
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, "");
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, "");
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, "");
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
// TokenLoan Contract.
// 
// ----------------------------------------------------------------------------
contract TokenLoan {
    using SafeMath for uint;

    address public owner;

    address[] public acceptedTokens;
    address[] public collateralContracts;
    mapping(address => bool) validCC;
    mapping(uint => bool) public removedTokens;
    mapping(uint => string) public tokenNames;
    mapping(bytes32 => uint) public tokenIndexLookUp;
    mapping(uint => mapping(address => uint)) public userTokenBalances;
    mapping(uint => uint) public totalTokenBalances;

    

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not the contract owner.");
        _;
    }

    modifier OnlyCollateralContract {
        require(validCC[msg.sender], "You are not a valid Collateral Contract.");
        _;
    }

    function addToken (address _tokenAddress, string memory _tokenName) public onlyOwner {
        acceptedTokens.push(_tokenAddress);
        tokenNames[acceptedTokens.length.sub(1)] = _tokenName;
    } 

    function removeToken (uint _tokenIndex) public onlyOwner {
        removedTokens[_tokenIndex] = true;
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }

    function lookUpTokenIndex (string memory _tokenName) public view returns(uint) {
        bytes32 bytes32String = stringToBytes32(_tokenName);
        return tokenIndexLookUp[bytes32String];
    }

    function updateAllTotalTokenBalances () public {
        for (uint i = 0; i < acceptedTokens.length; i++) {
            if (!removedTokens[i]) {
                totalTokenBalances[i] = ERC20Interface(acceptedTokens[i]).balanceOf(address(this));
            }
        }
    }

    function updateUserBalances(uint _token, uint _balance, address _user) public OnlyCollateralContract {
        userTokenBalances[_token][_user] = _balance;
    }

    function sendStuckTokens (address _user, uint _token, uint _amount) public onlyOwner {
        ERC20Interface(acceptedTokens[_token]).transfer(_user, _amount);
    }
}




// ----------------------------------------------------------------------------
// Collateral Contract.
// 
// ----------------------------------------------------------------------------
contract Collateral {

    address payable user;
    address tokenLoanContract;
    uint[] expectedTokens;

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
    }


    constructor (uint[] memory _tokens, address payable _user, address _TokenLoanContract) public {
        user = _user;
        for (uint i = 0; i < _tokens.length; i++) {
            expectedTokens.push(_tokens[i]);
        }
    }

    function updateUserBalance() public {
        for (uint i = 0; i < expectedTokens.length; i++) {
            TokenLoan(tokenLoanContract).updateUserBalances(expectedTokens[i], 
                ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this)), 
                user);
        }
    }

    function sendBack() public onlyTokenLoan {
        for (uint i = 0; i < expectedTokens.length; i++) {
            uint balance = ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).transfer(user, balance);
            }
        }
    }

    function sendAuctionWinner(address _winner) public onlyTokenLoan {
        for (uint i = 0; i < expectedTokens.length; i++) {
            uint balance = ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoan(tokenLoanContract).acceptedTokens(expectedTokens[i])).transfer(_winner, balance);
            }
        }
    }
}