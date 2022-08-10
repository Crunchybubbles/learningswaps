import brownie
from brownie import accounts, Contract, vyper_router, TickTest


def fix_path(path, amountIn):
    path = list(path)
    path0 = list(path[0])
    if path[0][0] == 0:
        path0[4] = amountIn
    if path[0][0] == 1:
        path0[7] = amountIn
    path[0] = tuple(path0)
    path = tuple(path)
    return path
        
def sortSecond(val):
    return val[1]

def calc_amountIn(path):
    initialIn = 10**17
    delta = 10**15
    most = 0
    amount = 0

    tt = TickTest[-1]
    try:
        mid_in = initialIn
        mid_path = fix_path(path, mid_in)
        #print(mid_path)
        mid = tt.check_path(mid_path)
        mid_profit = mid[-1][5] - mid_in
    except:
        print("no mid")
    try:
        low_in = mid_in - delta
        low_path = fix_path(path, low_in)
        #print(low_path)
        low = tt.check_path(low_path)
        low_profit = low[-1][5] - low_in
    except:
        print("no low")
    try:
        high_in = mid_in + delta
        high_path = fix_path(path, high_in)
        #print(high_path)
        high = tt.check_path(high_path)
        high_profit = high[-1][5] - high_in
    except:
        print("no high")
    prof = [("low", low_profit), ("mid", mid_profit), ("high", high_profit)]
    g = 0
    for i, p in enumerate(prof):
        if p[1] > g:
            g = p[1]
            best = i
    direction = best

    while True:
        if direction == 0:
            initialIn -= delta
        elif direction == 1:
            break
        elif direction == 2:
            initialIn += delta

        new_path = fix_path(path, initialIn)
        r = tt.check_path(new_path)
        profit = r[-1][5] - initialIn

        if profit > most:
            most = profit
            amount = initialIn
        else:   
            if direction == 0:
                initialIn += delta
            elif direction == 1:
                break
            elif direction == 2:
                initialIn -= delta

            delta = delta / 2
            #print(delta)
            #print(most, amount)
            if delta > 100:
                return most, amount

            
        
        
        
    
    
            
    


def main():
    # dai = Contract("0x6b175474e89094c44da98b954eedeac495271d0f")
    # whale = "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643"
    # bal = dai.balanceOf(whale)
    # dai.transfer(accounts[0], bal, {"from": whale})

    
    # WETH="0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    # weth = Contract(WETH)
    # weth_whale="0xf04a5cc80b1e94c69b48f5ee68a08cd2f09a7c3e"
    # bal = weth.balanceOf(weth_whale)
    # weth.transfer(accounts[0], bal, {"from": weth_whale})

    tt = TickTest.deploy({"from": accounts[0]})
    #tt = TickTest[-1]
    

    # v = vyper_router.deploy({"from":accounts[0]})
    # weth.approve(v.address, (2**256) - 1, {"from": accounts[0]})

    path = ((1, '0x86d257cDB7bC9c0dF10E84C8709697F92770b335', '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', '0xD46bA6D942050d489DBd938a2C909A5d5039A161', 0, 471684127816, True, 0, 4295128740), (1, '0x0BEd31d1070a3713a2FcF0BE500b53774f73Acbb', '0xD46bA6D942050d489DBd938a2C909A5d5039A161', '0xdAC17F958D2ee523a2206206994597C13D831ec7', 0, 240252811, True, 471684127816, 4295128740), (1, '0x7858E59e0C01EA06Df3aF3D20aC7B0003275D4Bf', '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', '0xdAC17F958D2ee523a2206206994597C13D831ec7', 0, 240177233, False, 240252811, 1461446703485210103287273052203988822378723970341), (1, '0x6c6Bc977E13Df9b0de53b251522280BB72383700', '0x6B175474E89094C44Da98b954EedeAC495271d0F', '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', 0, 240059651007379943820, False, 240177233, 1461446703485210103287273052203988822378723970341), (1, '0xC2e9F25Be6257c210d7Adf0D4Cd6E3E881ba25f8', '0x6B175474E89094C44Da98b954EedeAC495271d0F', '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2', 0, 141948333618303688, True, 240059651007379943820, 4295128740))
    calc_amountIn(path)
    
    #dai.approve(v.address, (2**256) - 1, {"from": accounts[0]})
    
    # #prebal = 1000000
    #00000000000
    #v.swap_along_path(path, dai.address, dai.address, accounts[2], {"from": accounts[0]})
    #postbal = dai.balanceOf(accounts[2])
    #print(postbal - prebal)
    
    # pre = weth.balanceOf(accounts[0])
    # p = tt.check_path(path)
    # v.swap_along_path(p, WETH, WETH, accounts[0], {"from": accounts[0]})
    # post = weth.balanceOf(accounts[0])
    # print(post - pre)
