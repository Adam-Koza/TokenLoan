const { expectEvent, shouldFail, shouldNotFail } = require('openzeppelin-test-helpers');
const TokenLoan = artifacts.require("TokenLoan");
const TokenLoanStorage = artifacts.require("TokenLoanStorage");
const Auction = artifacts.require("Auction");
const Collateral = artifacts.require("Collateral");

const mode = process.env.MODE;

let TokenLoanInstance;
let TokenLoanStorageInstance;
let AuctionInstance;
let CollateralInstance;

contract("TokenLoan", accounts => {

    before(async function () {
        TokenLoanStorageInstance = await TokenLoanStorage.deployed();
        TokenLoanInstance = await TokenLoan.deployed();
        AuctionInstance = await Auction.deployed();
        // Add Logic Contract to Storage Contract.
        await TokenLoanStorageInstance.updateLogicContract(TokenLoanInstance.address);
        console.log("");
        console.log("Contructor:");
    });


    after("write coverage/profiler output", async () => {
        if (mode === "profile") {
            await global.profilerSubprovider.writeProfilerOutputAsync();
        } else if (mode === "coverage") {
            await global.coverageSubprovider.writeCoverageAsync();
        }
    });


    ////////////////////////////////////////
    //
    //          CONSTRUCTOR:
    //
    ////////////////////////////////////////


    it("should set owner correctly.", async () => {
        const owner = accounts[0];
        if (mode === "profile") {
            global.profilerSubprovider.start();
        }

        assert.equal(await TokenLoanInstance.owner(), owner);
        if (mode === "profile") {
            global.profilerSubprovider.stop();
        }
    });

    it("Should set storage contract correctly.", async () => {
        assert.equal(await TokenLoanInstance.storageContract(), TokenLoanStorageInstance.address);
    });



    ////////////////////////////////////////
    // 
    //          MODIFIERS:
    //
    ////////////////////////////////////////


    it("Should allow owner to call functions with the onlyOwner modifier.", async () => {
        console.log("");
        console.log("Modifiers:");
        const currentOwner = accounts[0];

        assert.equal(await TokenLoanInstance.owner(), currentOwner);
        await TokenLoanInstance.setAuctionContract(AuctionInstance.address);
        assert.equal(await TokenLoanInstance.auctionContract(), AuctionInstance.address);
    });


    it("Should fail if a non-owner calls functions with the onlyOwner modifier.", async () => {
        const nonOwner = accounts[1];

        await shouldFail.reverting(TokenLoanInstance.setAuctionContract(AuctionInstance.address, { from: nonOwner }));
        await shouldFail.reverting(TokenLoanInstance.sendStuckTokens(nonOwner, 0, 0, { from: nonOwner }));
    });

    it("Should allow collateral contract to call functions with the OnlyCollateralContract modifier.", async () => {
        const newUser = accounts[2];
        let returned = await TokenLoanInstance.createCollateralContract([], { from: newUser });
        CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
        await CollateralInstance.updateUserBalance();
        assert.equal(0, 0);
    });

    it("Should fail if a non-collateral contract calls functions with the OnlyCollateralContract modifier.", async () => {
        const nonContract = accounts[1];

        await shouldFail.reverting(TokenLoanInstance.updateUserBalances(0, 0, { from: nonContract }));
    });



    ////////////////////////////////////////
    //
    //          setAuctionContract:
    //
    ////////////////////////////////////////


    it("Should set auction contract address.", async () => {
        console.log("");
        console.log("setAuctionContract:");
        const currentOwner = accounts[0];

        assert.equal(await TokenLoanInstance.owner(), currentOwner);
        await TokenLoanInstance.setAuctionContract(AuctionInstance.address);
        assert.equal(await TokenLoanInstance.auctionContract(), AuctionInstance.address);
    });


    ////////////////////////////////////////
    //
    //          createCollateralContract:
    //
    ////////////////////////////////////////


    it("Should deploy new collateral contract.", async () => {
        console.log("");
        console.log("createCollateralContract:");
        const newUser = accounts[2];

        let returned = await TokenLoanInstance.createCollateralContract([0], { from: newUser });
        CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
        assert.equal(await CollateralInstance.user(), newUser);
    });

    it("Should increment loanID.", async () => {
        const newUser = accounts[2];
        let oldID = await TokenLoanStorageInstance.loanID();
        await TokenLoanInstance.createCollateralContract([0], { from: newUser });
        assert.equal(await TokenLoanStorageInstance.loanID() == oldID, false);
    });

    it("Should update loan struct.", async () => {
        const newUser = accounts[2];
        await TokenLoanInstance.createCollateralContract([0], { from: newUser });
        assert.equal(await TokenLoanStorageInstance.loanCollateralOwner(await TokenLoanStorageInstance.loanID()), newUser);
    });

    it("Should add collateral contract to valid collateral mapping.", async () => {
        const newUser = accounts[2];
        let returned = await TokenLoanInstance.createCollateralContract([0], { from: newUser });
        CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
        assert.equal(await TokenLoanStorageInstance.validCollateralContract(CollateralInstance.address), true);
    });

    it("Should update loan index lookup mapping.", async () => {
        const newUser = accounts[2];
        let returned = await TokenLoanInstance.createCollateralContract([0], { from: newUser });
        CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
        assert.equal(await TokenLoanStorageInstance.loanIndexLookUp(CollateralInstance.address) > 0, true);
    });


    ////////////////////////////////////////
    //
    //          checkLoan:
    //
    ////////////////////////////////////////


    it("Should create a new auction lot if loan is bad.", async () => {
        console.log("");
        console.log("checkLoan:");
        const newUser = accounts[2];

        let auctionID = await AuctionInstance.lotNumber();
        let loanID = await TokenLoanStorageInstance.loanID();
        await TokenLoanInstance.checkLoan(loanID, true, { from: newUser });
        assert.equal(await AuctionInstance.lotNumber() == auctionID, false);
    });

    it("Should send coins back to collateral owner is loan is good.", async () => {
        const newUser = accounts[4];
        await TokenLoanInstance.createCollateralContract([], { from: newUser });
        let tx = await TokenLoanInstance.checkLoan(await TokenLoanStorageInstance.loanID(), false, { from: newUser });
        assert.equal(tx.receipt.rawLogs.length > 0, true);
    });
});






contract("Auction", accounts => {

    before(async function () {
        TokenLoanStorageInstance = await TokenLoanStorage.deployed();
        TokenLoanInstance = await TokenLoan.deployed();
        AuctionInstance = await Auction.deployed();
        // Add Logic Contract to Storage Contract.
        await TokenLoanStorageInstance.updateLogicContract(TokenLoanInstance.address);
        console.log("");
        console.log("Contructor:");
    });


    after("write coverage/profiler output", async () => {
        if (mode === "profile") {
            await global.profilerSubprovider.writeProfilerOutputAsync();
        } else if (mode === "coverage") {
            await global.coverageSubprovider.writeCoverageAsync();
        }
    });


    ////////////////////////////////////////
    //
    //          CONSTRUCTOR:
    //
    ////////////////////////////////////////


    it("should set TokenLoan contract correctly.", async () => {
        const owner = accounts[0];
        if (mode === "profile") {
            global.profilerSubprovider.start();
        }

        assert.equal(await AuctionInstance.tokenLoanContract(), TokenLoanInstance.address);
        if (mode === "profile") {
            global.profilerSubprovider.stop();
        }
    });

    it("Should set soft close correctly.", async () => {
        assert.equal(await AuctionInstance.softClose(), 0);
    });


    ////////////////////////////////////////
    // 
    //          MODIFIERS:
    //
    ////////////////////////////////////////


    it("Should allow TokenLoan contract to call functions with the onlyTokenLoan modifier.", async () => {
        console.log("");
        console.log("Modifiers:");
        const newUser = accounts[5];

        let auctionID = await AuctionInstance.lotNumber();
        let loanID = await TokenLoanStorageInstance.loanID();
        await TokenLoanInstance.checkLoan(loanID, true, { from: newUser });
        assert.equal(await AuctionInstance.lotNumber() == auctionID, false);
    });


    it("Should fail if a non-contract calls functions with the onlyTokenLoan modifier.", async () => {
        const nonContract = accounts[5];

        await shouldFail.reverting(AuctionInstance.createNewAuction(AuctionInstance.address, 5, { from: nonContract }));
    });


    ////////////////////////////////////////
    // 
    //          submitBid:
    //
    ////////////////////////////////////////


    it("Should submit bid on tokenLot.", async () => {
        console.log("");
        console.log("submitBid:");
        const newUser = accounts[5];
        await AuctionInstance.submitBid(1, { from: newUser, value: 1000 });
        assert.equal(await AuctionInstance.twoHightestBidsDifference(1) == 1000, true);
    });

    it("Should submit higher bid on tokenLot.", async () => {
        const newUser = accounts[6];
        await AuctionInstance.submitBid(1, { from: newUser, value: 1001 });
        assert.equal(await AuctionInstance.twoHightestBidsDifference(1) == 1, true);
    });

    it("Should not submit lower bid on tokenLot.", async () => {
        const newUser = accounts[6];
        await AuctionInstance.submitBid(1, { from: newUser, value: 900 });
        assert.equal(await AuctionInstance.twoHightestBidsDifference(1) == 1, true);
    });


    ////////////////////////////////////////
    // 
    //          winningBidder:
    //
    ////////////////////////////////////////


    it("Should return winning bidder.", async () => {
        console.log("");
        console.log("winningBidder:");
        const winner= accounts[6];
        await AuctionInstance.winningBidder(1);
        assert.equal(await AuctionInstance.winningBidder(1), winner);
    });


    // ////////////////////////////////////////
    // // 
    // //          createNewAuction:
    // //
    // ////////////////////////////////////////


    // it("Should create a new auction.", async () => {
    //     console.log("");
    //     console.log("createNewAuction:");
    //     const newUser = accounts[5];

    //     let auctionID = await AuctionInstance.lotNumber();
    //     await TokenLoanInstance.checkLoan(3, true, { from: newUser });
    //     assert.equal(await AuctionInstance.lotNumber() == auctionID, false);
    // });


});