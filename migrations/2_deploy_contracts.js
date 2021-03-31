const CHCToken = artifacts.require("CHCToken");
const WoodToken = artifacts.require("WoodToken");
const Smit = artifacts.require("SmitCoin");
const Slick = artifacts.require("Token");
const Ham = artifacts.require("HAM");
const Bank = artifacts.require("Bank");

module.exports = async function (deployer) {
  // deploy my contracts
  await deployer.deploy(CHCToken, "1000000000000000000000000");
  const CHCtoken = await CHCToken.deployed();

  await deployer.deploy(WoodToken);
  const woodToken = await WoodToken.deployed();

  await deployer.deploy(Smit);
  const smitToken = await Smit.deployed();

  await deployer.deploy(Slick);
  const slickToken = await Smit.deployed();

  await deployer.deploy(Ham);
  const hamToken = await Smit.deployed();

  await deployer.deploy(Bank);
};
