const CHCToken = artifacts.require("CHCToken");
const WoodToken = artifacts.require("WoodToken");
const Smit = artifacts.require("SmitCoin");
const Slick = artifacts.require("Token");
const Ham = artifacts.require("HAM");

module.exports = async function (deployer) {
  // deploy my contracts
  await deployer.deploy(CHCToken, "1000000000000000000000000");
  await deployer.deploy(WoodToken);
  await deployer.deploy(Smit);
  await deployer.deploy(Slick);
  await deployer.deploy(Ham);
};
