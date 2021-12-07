import { ethers } from "hardhat";

async function main() {
  // ADDRESS TO MINT TO:
  const toAddress = "0x08a80B42f8499C1C3f9e352632fB87E38F5Cbc80";

  console.log("\n\n 🎫 Minting to " + toAddress + "...\n");

  const smileys = await ethers.getContractAt(
    "Smileys",
    "0x81586aFEBB807697B7D7Aa4231001e539E188dcf"
  );

  // const result = await smileys.mintItem();
  // await result.wait();
  const tokenURI = await smileys.tokenURI(1);
  console.log(tokenURI);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
