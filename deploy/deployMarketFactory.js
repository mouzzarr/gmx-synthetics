const { hashString } = require("../utils/hash")

const func = async ({
  getNamedAccounts,
  deployments,
}) => {
  const { deploy, get, execute } = deployments
  const { deployer } = await getNamedAccounts()

  const { address: roleStoreAddress } = await get("RoleStore");
  const { address: marketStoreAddress } = await get("MarketStore");

  const { newlyDeployed, address } = await deploy("MarketFactory", {
    from: deployer,
    log: true,
    args: [roleStoreAddress, marketStoreAddress]
  })

  if (newlyDeployed) {
    await execute("RoleStore", { from: deployer, log: true }, "grantRole", address, hashString("CONTROLLER"))
  }
}
func.tags = ["MarketFactory"]
func.dependencies = ["RoleStore", "MarketStore"]
module.exports = func
