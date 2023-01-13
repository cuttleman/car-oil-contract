import { ethers } from "hardhat";

async function main() {
  const CarOil = await ethers.getContractFactory("CarOil");
  const carOil = await CarOil.deploy({ value: 0.01 });

  await carOil.deployed();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
