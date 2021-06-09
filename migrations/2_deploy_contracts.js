const CHCToken = artifacts.require("CHCToken");
const WoodToken = artifacts.require("WoodToken");
const Smit = artifacts.require("SmitCoin");
const Slick = artifacts.require("Token");
const Ham = artifacts.require("HAM");
const Bank = artifacts.require("Bank");
const Oracle = artifacts.require("ExchangeOracle");
const NFTLoan = artifacts.require("NFTLoan");

module.exports = async function (deployer) {
  // deploy my contracts
  await deployer.deploy(CHCToken, "1000000000000000000000000");
  const CHCtoken = await CHCToken.deployed();

  await deployer.deploy(Oracle);
  const oracle = await Oracle.deployed();

  await deployer.deploy(
    Bank,
    "0x433c6e3d2def6e1fb414cf9448724efb0399b698",
    oracle.address
  );
  const bank = await Bank.deployed();
};
