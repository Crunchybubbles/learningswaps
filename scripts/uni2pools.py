import brownie

from brownie import accounts, FlashBotsUniswapQuery, interface
import json


univ2facaddr = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f"
sushifacaddr = "0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac"

fbquery = "0x5EF1009b9FCD4fec3094a5564047e190D72Bd511"


def get_pools(fac_addr, faclen, fbquery):
    fbq = FlashBotsUniswapQuery.at(fbquery)
    start = 0
    end = 0
    if faclen < 1000:
        end = faclen
    else:
        end = 1000
    pools = {}
    while end <= faclen:
        r = fbq.getPairsByIndexRange(fac_addr, start, end)
        addrs = []
        for ppp in r:
            addrs += [ppp[2]]
        #print(addrs)
        reserves = fbq.getReservesByPairs(addrs)
        addrs = []
        for i, p in enumerate(r):
            pools[p[2]] = {"id": p[2], "token0":{"id":p[0], "reserves": reserves[i][0]}, "token1":{"id":p[1], "reserves": reserves[i][1]}, "timestamp": reserves[i][2]}
            
        start = end + 1
        if end == faclen:
            break
        elif start + 1000 < faclen:
            end = start + 1000
        else:
            end = faclen
    return pools

# def get_reserves(fac_addr, faclen, fbquery):
#     pools = get_pools(fac_addr, faclen, fbquery)
#     d = {}
#     fbq = FlashBotsUniswapQuery.at(fbquery)
#     start = 0
#     end = 0
#     if start + 1000 > len(pools):

    
#     r = fbq.getReservesByPairs(pools[:][2])
#     for p, i in enumerate(r):
#         d[pools[i][2]] = {"token0":{"id": pools[i][0], "reserve0": p[0]}, "token1":{"id": pools[i][1], "reserve1": p[2]}, "timestamp": p[0]}
#     return d

def save_pool_info(fac_addr, faclen, fbquery, name):
    info = get_pools(fac_addr, faclen, fbquery)
    f = open(f"{name}", "w")
    f.write(json.dumps(info))
    f.close()

def load_file_json(name):
    f = open(f"{name}")
    info = json.load(f)
    f.close()
    return info

def main():
    #sushipools = get_pools(sushifacaddr, 3052, fbquery)
    #print(sushipools)
    #for pool in sushipools:
    #    print(pool)
    #d = get_reserves(sushifacaddr, 3052, fbquery)
    #save_pool_info(sushifacaddr, 3052, fbquery, "sushipools.txt")
    #sushipools = load_file_json("sushipools.txt")
    #print(sushipools)
    # for k,v in sushipools.items():
    #     print(k)
    #     print(v)
    #save_pool_info(univ2facaddr, 84932, fbquery, "univ2pools.txt")
    univ2pools = load_file_json("univ2pools.txt")
    # for k, v in univ2pools.items():
    #     print(k)
    #     print(v)
    print(len(univ2pools))
