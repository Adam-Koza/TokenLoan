const TokenLoanStorage = artifacts.require("TokenLoanStorage");
const TokenLoan = artifacts.require("TokenLoan");
const Auction = artifacts.require("Auction");

module.exports = function (deployer) {
  deployer.deploy(TokenLoanStorage).then(function () {
    return deployer.deploy(TokenLoan, TokenLoanStorage.address).then(function () {
      return deployer.deploy(Auction, TokenLoan.address, 0);
    });
  });
};
