import brownie
from brownie import Contract, accounts, flash, history
#from brownie.network import priority_fee


#aave_lending_pool = "0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5"
#aave_lending_pool = "0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9"
#weth = Contract("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
#weth_whale = "0x2f0b23f53734252bda2277357e97e1517d6b042a"

yfi = "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e"
dai = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
weth = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
buyer = "0x6903223578806940bd3ff0C51f87aa43968424c8"
binance8 = "0xf977814e90da44bfa03b6295a0616a897441acec"
yfi_eth = "0x04916039B1f59D9745Bf6E0a21f191D1e0A84287"
def get_token_from_whale(token, whale, to):
    token.transfer(to, token.balanceOf(whale), {"from": whale})

def yfi_dump(f):
    c = Contract(yfi)
    get_token_from_whale(c, binance8, f.address)
#    c.approve(f, (2**256 - 1), {"from": accounts[0]})
    print(c.balanceOf(f.address))
    print(f.balance())
    f.dump_yfi({"from": accounts[0]})
    print(c.balanceOf(f.address))
    print(Contract(weth).balanceOf(f.address))
    #Contract(yfi_eth).swap(accounts[0], True, 10**18, 0, b"", {"from": accounts[0]})


    
def main():
    #priority_fee("2 gwei")
    WETH = Contract(weth)
    f = flash.deploy({"from": accounts[0]})
#    f.approve_tokens({"from": accounts[0]})
    #yfi_dump(f)    
    f.check({"from":accounts[0]})
    print(history[-1].call_trace(True))
    #    f.approve_all({"from": accounts[0]})
#    print(WETH.balanceOf(f.address))
#    f.flash_call([yfi], ["0.059 ether"], [0], b"", 0, {"from": accounts[0]})
#    print(WETH.balanceOf(f.address))
    #    get_token_from_whale(weth, weth_whale, f.address)
#    f.approve(weth.address, {"from": accounts[0]})
#    weth.transfer(f.address, weth.balanceOf(accounts[0]), {"from": accounts[0]})
#    f.flash_call([weth.address], [10**19],[0],b"3", 0, {"from": accounts[0]})


    
