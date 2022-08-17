import brownie
from brownie import accounts, Contract, TickTest, vyper_router


def deploy(contract):
    return contract.deploy({"from": accounts[0]})


def main():

    yfi = Contract("0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e")
    weth = Contract("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
    weth.deposit({"from": accounts[0], "value": accounts[0].balance()/2})

    
    v = deploy(vyper_router)
    c = deploy(TickTest)


    pool = "0x04916039B1f59D9745Bf6E0a21f191D1e0A84287"
    zf1 = False
    amount = weth.balanceOf(accounts[0])
    pricelimit = 1461446703485210103287273052203988822378723970341
    
    (a0, a1) = c.calc_v3_swap(pool, zf1, amount, pricelimit)
    print(a0, a1)

    pool_type = 1
    pool = pool
    token0 = yfi.address
    token1 = weth.address
    amountIn = 0
    amountOut = 0
    zf1 = zf1
    spl = pricelimit
    params = (pool_type, pool, token0, token1, amountIn, amountOut, zf1, amount, spl)
    
    path = [params]

    
    weth.approve(v.address, (2**256) - 1, {"from": accounts[0]})
    v.swap_along_path(path, weth.address, yfi.address, accounts[0], {"from": accounts[0]})
    
    print(yfi.balanceOf(accounts[0]))
                        
    
