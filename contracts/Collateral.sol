pragma solidity 0.5.0;

import "./SafeMath.sol";
import "./TokenLoan.sol";
import "./TokenLoanStorage.sol";
import "./ERC20Interface.sol";


// ----------------------------------------------------------------------------
// Collateral Contract.
// 
// ----------------------------------------------------------------------------
contract Collateral {
    using SafeMath for uint;

    event CollateralReturned(address _to, uint256 _timestamp);

    address payable public user;
    address tokenLoanContract;
    address auctionContract;
    address storageContract;
    uint[] expectedTokens;

    modifier onlyTokenLoan {
        require(msg.sender == tokenLoanContract, "You are not the TokenLoan Contract.");
        _;
    }

    modifier onlyAuction {
        require(msg.sender == auctionContract, "You are not the TokenLoan Contract.");
        _;
    }


    constructor (uint[] memory _tokens, address payable _user, address _tokenLoanContract, address _storageContract, address _auctionContract) public {
        user = _user;
        tokenLoanContract = _tokenLoanContract;
        auctionContract = _auctionContract;
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
        emit CollateralReturned(user, now);
    }

    function sendAuctionWinner(address _winner) external onlyAuction {
        for (uint i = 0; i < expectedTokens.length; i = i.add(1)) {
            uint balance = ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).balanceOf(address(this));
            if (balance > 0) {
                ERC20Interface(TokenLoanStorage(storageContract).acceptedTokens(expectedTokens[i])).transfer(_winner, balance);
            }
        }
    }
}