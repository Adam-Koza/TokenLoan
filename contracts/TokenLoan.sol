pragma solidity 0.5.6;

import "./SafeMath.sol";
import "./TokenLoanStorage.sol";
import "./ERC20Interface.sol";
import "./Collateral.sol";
import "./Auction.sol";

// ----------------------------------------------------------------------------
// TokenLoan (Logic) Contract.
// 
// ----------------------------------------------------------------------------
contract TokenLoan {
    using SafeMath for uint;

    event NewCollateralAddress(address _newAddress, address _by, uint256 _timestamp);

    address public owner;
    address payable public storageContract;
    address public auctionContract;
    TokenLoanStorage contractStorage;
    Auction auction;


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

    function setAuctionContract (address _auctionContract ) external onlyOwner {
        auctionContract = _auctionContract;
        auction = Auction(auctionContract);
    }

    function createCollateralContract (uint[] calldata _tokens) external returns (address) {
        Collateral newCollateralContract = new Collateral(_tokens, msg.sender, address(this), storageContract, auctionContract);
        contractStorage.incrementLoanID();
        contractStorage.updateLoan(contractStorage.loanID(), msg.sender, address(newCollateralContract), true, 0, 0, _tokens);
        contractStorage.setValidCollateralContract(address(newCollateralContract), true);
        contractStorage.updateLoanIndexLookUp(address(newCollateralContract), contractStorage.loanID());
        emit NewCollateralAddress(address(newCollateralContract), msg.sender, now);
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
    function checkLoan (uint _loanID, bool _isBad) external {
        // Query oracle. Assume loan is bad, auction of the Collateral.
        if (_isBad) {
            startAuction(_loanID);
        } else {
        // Loan is good, send the Collateral back to it's owner.
            Collateral(contractStorage.loanCollateralAddress(_loanID)).sendBack();
        }
    }

    function lookUpTokenIndex (string calldata _tokenName) external view returns (uint) {
        bytes memory bytesName = bytes(_tokenName);
        bytes32 key = keccak256(bytesName);
        return contractStorage.tokenIndexLookUp(key);
    }


    function sendStuckTokens (address _user, uint _token, uint _amount) external onlyOwner {
        ERC20Interface(contractStorage.acceptedTokens(_token)).transfer(_user, _amount);
    }
}

