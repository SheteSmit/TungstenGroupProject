const Bank = artifacts.require("Bank");
const Oracle = artifacts.require("ExchangeOracle");

module.exports = async function (deployer) {
  await deployer.deploy(Oracle);
  const oracle = await Oracle.deployed();

  await deployer.deploy(
    Bank,
    "0x433c6e3d2def6e1fb414cf9448724efb0399b698",
    oracle.address
  );
  const bank = await Bank.deployed();
};
