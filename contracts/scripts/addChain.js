const { ethers } = require("hardhat");
const addChain = async (destinationDomain, destinationReceiver, relayerGas) => {
  const promotion = await ethers.getContractAt(
    "PromotionMain",
    "0x70916226F39673412eB2503f9e07f05a2ab12182"
  );
  const args = [destinationDomain, destinationReceiver, relayerGas];
  console.log(`Adding Chain at ${promotion.address} with ${args}`);
  const addChainTx = await promotion.addChain(
    destinationDomain,
    destinationReceiver,
    relayerGas
  );
  const addChainReceipt = await addChainTx.wait(1);
  console.log(`Chain addded at Domain ${destinationDomain} with Hyperlane `);
};

addChain(44787, "0x9A6AD921268b991eBE919A478CD4A82F30F4A5e0", 1200000)
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
