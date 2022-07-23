import brownie
from brownie import history

#wip = "0xE7eD6747FaC5360f88a2EFC03E00d25789F69291"
wip = "0xe0aA552A10d7EC8760Fc6c246D391E698a82dDf9"
weth = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"


def main():
    weth1 = 0
    weth2 = 0
    for h in history[-1].subcalls:
        if 'function' in h.keys():
            if h['function'] == 'transfer(address,uint256)':
                if h['to'] == weth and h['inputs']['dst'] ==  wip:
                    weth1 = h['inputs']['wad']
                if h['from'] == wip and h['to'] == weth:
                    weth2 = h['inputs']['wad']

    print(weth1)
    print(weth2)
    print( (weth1 - weth2) * 10**-18)
