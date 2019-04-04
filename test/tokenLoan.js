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

    // it("Should allow collateral contract to call functions with the OnlyCollateralContract modifier.", async () => {
    //     const newUser = accounts[2];
    //     let returned = await TokenLoanInstance.createCollateralContract([0], { from: newUser });
    //     CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
    //     await CollateralInstance.updateUserBalance();
    //     assert.equal(0, 0);
    // });

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


    // it("Should create a new auction lot if loan is bad.", async () => {
    //     console.log("");
    //     console.log("startAuction:");
    //     const newUser = accounts[2];

    //     let returned = await TokenLoanInstance.createCollateralContract([0], { from: newUser });
    //     CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
    //     assert.equal(await CollateralInstance.user(), newUser);
    // });

    // it("Should send coins back to collateral owner is loan is good.", async () => {
    //     console.log("");
    //     console.log("startAuction:");
    //     const newUser = accounts[2];

    //     let returned = await TokenLoanInstance.createCollateralContract([0], { from: newUser });
    //     CollateralInstance = await Collateral.at(returned.logs[0].args._newAddress);
    //     assert.equal(await CollateralInstance.user(), newUser);
    // });





});


