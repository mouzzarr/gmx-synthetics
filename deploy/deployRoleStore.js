const { hashString } = require("../utils/hash")

const func = async ({
  getNamedAccounts,
  deployments,
}) => {
  const { deploy, execute } = deployments
  const { deployer } = await getNamedAccounts()

  const { newlyDeployed } = await deploy("RoleStore", {
    from: deployer,
    log: true,
  })

  if (newlyDeployed) {
    await execute("RoleStore", { from: deployer, log: true }, "grantRole", deployer, hashString("CONTROLLER"))
    await execute("RoleStore", { from: deployer, log: true }, "grantRole", deployer, hashString("ORDER_KEEPER"))
  }
}
func.tags = ["RoleStore"]
module.exports = func
