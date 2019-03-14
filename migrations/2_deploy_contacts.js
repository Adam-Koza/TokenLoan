const TokenLoan = artifacts.require("TokenLoan");

module.exports = function(deployer) {
  deployer.deploy(TokenLoan);
};
