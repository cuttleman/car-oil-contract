import { ethers, upgrades } from "hardhat";

async function main() {
  const CarOil = await ethers.getContractFactory("CarOil");
  const carOil = await upgrades.deployProxy(CarOil);

  await carOil.deployed();

  console.log("Deployed Address:", carOil.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
