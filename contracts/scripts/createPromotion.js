const { ethers, network } = require("hardhat");
const propose = async (
  destinationDomain,
  claimsPerPerson,
  badgeURI,
  groupId,
  _salt
) => {
  const promotion = await ethers.getContractAt(
    "PromotionMain",
    "0x70916226F39673412eB2503f9e07f05a2ab12182"
  );
  const args = [claimsPerPerson, badgeURI, groupId, destinationDomain, _salt];
  console.log(`Creating promotion at ${promotion.address} with ${args}`);
  const relayerFee = (
    await promotion.getQuotedPayment(destinationDomain)
  ).toString();
  console.log("This is the relayer Fee: " + relayerFee);
  const promotionTx = await promotion.createPromotion(
    claimsPerPerson,
    badgeURI,
    groupId,
    destinationDomain,
    _salt,
    { value: relayerFee }
  );
  const promotionReceipt = await promotionTx.wait(1);
  // const promotionData = promotionReceipt.logs[6].data.toString();

  console.log(
    `Promotion created at Domain ${destinationDomain} with Hyperlane `
  );
};

propose(
  44787,
  3,
  "https://ipfs.io/ipfs/bafybeibv36rkxbqbea7k5jzjtg7t73pegmfn4xebmnlfx66p5eioegylwa",
  "0x7b34eb2dea09f26fc6d00449b5ebc0d0",
  69
)
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.log(err);
    process.exit(1);
  });
