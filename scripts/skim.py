import brownie
from brownie import accounts, Contract, univ2skim, interface, history


sushi = "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac"

def get_uni2_pools(factory):
    fb = Contract("0x5EF1009b9FCD4fec3094a5564047e190D72Bd511")
    fac = Contract(factory)
    pairs_length = fac.allPairsLength()
    pools = []
    start = 0
    stop = 10

    goOn = True
    while goOn:
        print(start, stop)
        q = fb.getPairsByIndexRange(factory, start, stop)    
        pools += [q]
        start = stop
        if stop + 10 < pairs_length:
            stop = stop + 10
        else:
            stop = pairs_length
        if start == stop:
            goOn = False
    return pools


def save_sushi():
    f = open("sushi_pools.txt", "w")
    pools = get_uni2_pools(sushi)
    f.write(str(pools))
    f.close()

def load_sushi():
    f = open("sushi_pools.txt")
    pools = f.read()
    f.close()
    return pools

def sushi_list():
    pools = load_sushi()
    temp = ""
    token0 = ""
    token1 = ""
    address = ""
    collecting = False
    count = 0
    pool_list = []
    for c in pools:
        if c == "'" and not collecting:
            collecting = True
        elif c == "'" and collecting:
            if count == 0:
                token0 = temp
            elif count == 1:
                token1 = temp
            elif count == 2:
                address = temp
            collecting = False
#            print(temp)
            temp = ""
            count = (count + 1) % 3

        elif collecting:
            temp = temp + c
#            print(temp)
        elif token0 != "" and token1 != "" and address != "":
#            print(token0, token1, address)
            pool_list += [(token0, token1, address)]
            token0 = ""
            token1 = ""
            address = ""
    return pool_list
        
    

            

def main():
#    print(get_uni2_pools(sushi))
#    save_sushi()
    c = univ2skim.deploy({"from": accounts[0]})
    pools = sushi_list()
    for pool in pools:
        c.off_the_top(pool[2], {"from": accounts[0]})
        print(history[-1].info())
        print(pool[0], interface.ERC20(pool[0]).balanceOf(c.address))
        print(pool[1], interface.ERC20(pool[1]).balanceOf(c.address))
#    print(len(pools))
