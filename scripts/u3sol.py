import brownie
from brownie import accounts, Uni3ticks
from brownie.network import priority_fee
import requests as r
import math

class Uni3Pool:
    def __init__(self, query):
        self.address = query['id']
        self.token0 = query['token0']
        # self.token0_symbol = token0_symbol
        # self.token0_decimals = decimals0
        # self.token1 = token1
        # self.token1_symbol = token1_symbol
        # self.token1_decimals = decimals1
        # self.fee = fee
        # self.createdAtblock = block
        # self.createdAtTime = Time
        # self.ticks = ticks
        # self.current_tick = current_tick
        
        

    

MAX_U256 = ((2**256) - 1)
MAX_U160 = ((2**160) - 1)
MIN_TICK = -887272
MAX_TICK = 887272

def do_request(query):
    req = r.post('https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3',json={'query':query})
    if req.status_code == 200:
        return req.json()
    else:
        raise Exception(f'Failed with return code {req.status_code, query}')
    
def getAllPools():
    uni3pools = []
    query1 = """
    {pools(first:1,orderBy:createdAtTimestamp,orderDirection:asc) { 
    id,
    token0 {id,symbol,decimals},
    token1{id,symbol,decimals},
    feeTier,
    createdAtBlockNumber,
    createdAtTimestamp,
    liquidity,
    sqrtPrice,
    token0Price,
    token1Price
    tick,
    ticks(where:{liquidityNet_gt: 0}, orderBy:tickIdx, orderDirection:asc){
        tickIdx,
        liquidityNet,
        liquidityGross,
        price0,
        price1
    }
    }}
    """
    request1 = do_request(query1)
    for pool in request1['data']['pools']:
        uni3pools += [pool]
        #print(pool.keys())
    #print(uni3pools)
    goOn = False
    while goOn:
        lastTime = uni3pools[-1]['createdAtTimestamp']
        print(lastTime)
        query2_1 = "{pools(first:1000,orderBy:createdAtTimestamp,orderDirection:asc where:{createdAtTimestamp_gt:"
        query2_3 = "}){id,token0{id,symbol,decimals},token1{id,symbol,decimals},feeTier,createdAtBlockNumber,createdAtTimestamp,liquidity,sqrtprice,token0Price,token1Price,tick,ticks(where:{liquidityNet_gt: 0}, orderBy:tickIdx, orderDirection:asc){id,tickIdx,liquidityNet,liquidityGross,price0,price1}}}"
        query = query2_1 + lastTime + query2_3
        requestN = do_request(query)
        if requestN['data']['pools'] == []:
            #print(requestN)
            goOn = False
            break
        for pool in requestN['data']['pools']:
            uni3pools += [pool]
    print(len(uni3pools))
    return uni3pools



    
    

def getPools():
    query = """

{
    pool(id: "0x04916039b1f59d9745bf6e0a21f191d1e0a84287") {
    id,
    token0{id, symbol},
    token1{id, symbol},
    feeTier,
    liquidity,
    ticks(where: {liquidityNet_gt: 0}, orderBy: tickIdx, orderDirection: asc) {
        tickIdx,
        liquidityNet
    }
    
    }
    
}
    """
    req = r.post('https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3',json={'query':query})
    if req.status_code == 200:
        return req.json()
    else:
        raise Exception(f'Failed with return code {req.status_code, query}')

def getPools_Ticks(addrs):
    result = []
    for a in addrs:
        query1 = "{pool(id:"
        query2 = f'"{a}")'
        query3 = "{id ticks(where: {liquidityNet_gt: 0}, orderBy: tickIdx, orderDirection: asc) {tickIdx liquidityNet}}}"
        query = query1 + query2 + query3
#        print(query)
        req = r.post('https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3',json={'query':query})
        if req.status_code == 200:
#            print(result)
            result += [req.json()]
        else:
            raise Exception(f'Failed with return code {req.status_code, query}')
    _addresses = []
    _ticks = []
    
    for i in result:
        ticks = i['data']['pool']['ticks']
        address = i['data']['pool']['id']
#        print(address)
        TICKS = []
        for t in ticks:
            TICKS += [t['tickIdx']]
        _addresses += [address]
        _ticks += [TICKS]
    return (_addresses, _ticks)


def getAmount0Delta(priceA, priceB, liquidity, roundUp):
    if priceA > priceB:
        t = priceA
        priceA = priceB
        priceB = t
    numerator1 = liquidity << 96
    numerator2 = priceB - priceA
    return (((numerator1 * numerator2) / priceB) / priceA)

def getAmount1Delta(priceA, priceB, liquidity, roundUp):
    if priceA > priceB:
        t = priceA
        priceA = priceB
        priceB = t
    return ((liquidity * (priceB - priceA)) / 96) 

def amount0Delta(priceA, priceB, liquidity):
    if liquidity < 0:
        return -getAmount0Delta(priceA, priceB, liquidity, False)
    else:
        return getAmount0Delta(priceA, priceB, liquidity, True)

    
def amount1Delta(priceA, priceB, liquidity):
    if liquidity < 0:
        return -getAmount1Delta(priceA, priceB, liquidity, False)
    else:
        return getAmount1Delta(priceA, priceB, liquidity, True)

def ticksAndAddr(pool):
    address = pool['id']
    ticks = []
    for tick in pool['ticks']:
        ticks += [int(tick['tickIdx'])]
    return (address, ticks)

def getSqrtPriceFromTick(tick):
    tick = int(tick)
    absTick = abs(tick)
    assert absTick <= MAX_TICK
    if absTick & 0x1 != 0:
        ratio = 0xfffcb933bd6fad37aa2d162d1a594001
    else:
        ratio = 0x100000000000000000000000000000000
    if absTick & 0x2 != 0:
        ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128
    if absTick & 0x4 != 0:
        ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128
    if absTick & 0x8 != 0:
        ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128
    if absTick & 0x10 != 0:
        ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128
    if absTick & 0x20 != 0:
        ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128
    if absTick & 0x40 != 0:
        ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128
    if absTick & 0x80 != 0:
        ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128
    if absTick & 0x100 != 0:
        ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128
    if absTick & 0x200 != 0:
        ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128
    if absTick & 0x400 != 0:
        ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128
    if absTick & 0x800 != 0:
        ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128
    if absTick & 0x1000 != 0:
        ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128
    if absTick & 0x2000 != 0:
        ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128
    if absTick & 0x4000 != 0:
        ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128
    if absTick & 0x8000 != 0:
        ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128
    if absTick & 0x10000 != 0:
        ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128
    if absTick & 0x20000 != 0:
        ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128
    if absTick & 0x40000 != 0:
        ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128
    if absTick & 0x80000 != 0:
        ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128
    if tick > 0:
        ratio = MAX_U256 / ratio

    if ratio % (1 << 32) == 0:
        p2 = 0
    else:
        p2 = 1
    sqrtPrice = (ratio >> 32) + p2
    return sqrtPrice

def mulDiv(n1, n2, d):
    n1 = int(n1)
    n2 = int(n2)
    d = int(d)
    return ((n1 * n2) / d)

def mulDivRoundingUp(n1, n2, d):
    n1 = int(n1)
    n2 = int(n2)
    d = int(d)
    return math.ceil((n1*n2) / d)

def divRoundingUp(n, d):
    n = int(n)
    d = int(d)
    return math.ceil(n/d)

def getNextPriceFromAmount0RoundingUp(price, liquidity, amount, add):
    if amount == 0:
        return price
    numerator1 = liquidity << 96
    if add:
        product = amount * price
        if (product / amount) == price:
            denominator = numerator1 + product
            if denominator >= numerator1:
                return mulDivRoundingUp(numerator1, price, denominator)
        return divRoundingUp(numerator1, ((numerator1 / price) + amount))
    else:
        denominator = numerator1 - (amount * price)
        return mulDivRoundingUp(numerator1, price, denominator)

def getNextPriceFromAmount1RoundingDown(price, liquidity, amount, add):
    if add:
        if amount <= MAX_U160:
            quotient = (int(amount) << 96) / liquidity
        else:
            quotient = mulDiv(amount, 96, liquidity)
        return price + quotient
    else:
        if amount <= MAX_U160:
            quotient = divRoundingUp(amount << 96, liquidity)
        else:
            quotient = mulDivRoundingUp(amount, 96, liquidity)
        assert price > quotient
        return price - quotient
        
                
def getNextPriceFromInput(price, liquidity, amountIn, zeroForOne):
    assert price > 0
    assert liquidity > 0
    if zeroForOne:
        return getNextPriceFromAmount0RoundingUp(price, liquidity, amountIn, True)
    else:
        return getNextPriceFromAmount1RoundingDown(price, liquidity, amountIn, True)

def getNextPriceFromOutput(price, liquidity, amountOut, zeroForOne):
    if zeroForOne:
        return getNextPriceFromAmount1RoundingDown(price, liquidity, amountOut, False)
    else:
        return getNextPriceFromAmount0RoundingUp(price, liquidity, amountOut, False)
    
    

def computeSwapStep(price_current, price_target, liquidity, amount_remaining, feePips):
    price_current = int(price_current)
    price_target = int(price_target)
    liquidity = int(liquidity)
    amount_remaining = int(amount_remaining)
    feePips = int(feePips)
    zeroForOne = price_current >= price_target
    exactIn = amount_remaining >= 0

    if exactIn:
        amountRemainingLessFee = mulDiv(amount_remaining, (10**6 - feePips), (10**6))
        if zeroForOne:
            amountIn = getAmount0Delta(price_target, price_current, liquidity, True)
        else:
            amountIn = getAmount1Delta(price_current, price_target, liquidity, True)
        if amountRemainingLessFee >= amountIn:
            price_next = price_target
        else:
            price_next = getNextPriceFromInput(price_current, liquidity, amountRemainingLessFee, zeroForOne)
    else:
        if zeroForOne:
            amountOut = getAmount1Delta(price_target, price_current, liquidity, False)
        else:
            amountOut = getAmount0Delta(price_current, price_target, liquidity, False)
        if abs(amount_remaining) >= amountOut:
            price_next = price_target
        else:
            price_next = getNextPriceFromOutput(price_current, liquidity, abs(amount_remaining), zeroForOne)

    is_max = price_target == price_next

    if zeroForOne:
        if is_max and exactIn:
            amountIn = amountIn
        else:
            amountIn = getAmount0Delta(price_next, price_current, liquidity, True)
        if is_max and not exactIn:
            amountOut = amountOut
        else:
            amountOut = getAmount1Delta(price_next, price_current, liquidity, False)
    else:
        if is_max and exactIn:
            amountIn = amountIn
        else:
            amountIn = getAmount1Delta(price_current, price_next, liquidity, True)
        if is_max and not exactIn:
            amountOut = amountOut
        else:
            amountOut = getAmount0Delta(price_current, price_next, liquidity, False)
    if not exactIn and (amountOut > abs(amount_remaining)):
        amountOut = abs(amount_remaining)
    if exactIn and (price_next != price_target):
        feeAmount = abs(amount_remaining) - amountIn
    else:
        feeAmount = mulDivRoundingUp(amountIn, feePips, ((10**6) - feePips))
    return (price_next, amountIn, amountOut, feeAmount)
#def index_of_tick(tick_Array, target):

#def v3swap(zeroForOne, amountSpecified, priceLimit):
    




def main():
#    priority_fee("2 gwei")
    # pool = "0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640"
    #yfi_eth =  "0x04916039b1f59d9745bf6e0a21f191d1e0a84287"
    #t = "0x2e5848efcfac935dd243c9094048ac346e198e1d"
    
    #ticks = [-138180,-23040,0,6960,7320,11280,12060,12780,14580,16080,16680,17700,17940,18780,19200,20040,20940,21180,21960,24000,24840,25080,25200,25800,26100,26340,26400,26580,26880,27060,27240,27360,27420,27540,28140,28320,28680,29700]
#    print(u.getTickData(yfi_eth, ticks))
    #u = Uni3ticks.deploy({"from": accounts[0]})
    #u = Uni3ticks[-1]
    #data = getPools()
    #pools = data['data']['pool']
 #   print(pools)
    uni3pools = getAllPools()
    print(uni3pools[0]['token0Price'])
    print(uni3pools[0]['token1Price'])
    print(uni3pools[0]['sqrtPrice'])
    priceFromTick = getSqrtPriceFromTick(uni3pools[0]['tick'])
    print(priceFromTick)
    # #    ticks = pools[0]['ticks']
    # addrs = []
#     # ticks = [[]]
    #print(ticksAndAddr(pools))

#     for p in pools:
#         addrs += [p['id']]
#     (addresses, ticks) = getPools_Ticks(addrs)
# #    print(addresses)
# #    print(ticks)
# #    print(u.getTickData(addresses[0], ticks[0]))
#     print(addresses, ticks)
    #(address, ticks) = ticksAndAddr(pools)
    #c = u.forPools([address], [ticks])
    #print(c[0])
#    tick_array = []
#    for i in c:
#        print(i)
        #     print(f"pool_addr {i[0]}")
#         print(f"current_price {i[1]}")
#         print(f"current_tick {i[2]}")
#         print(f"liquidity {i[3]}")
#         tick_array += i[4]
#         for tick in i[4]:
#             print(f"tickIdx {tick[0]}")
#             print(f"price_at_tick {tick[1]}")
#             print(f"liquitdityNet {tick[2]}")
# #         print("                                ")
    
    #print(c[0][1])
    # print(tick_array)
  #   currentPrice = c[0][1]
#     nextPrice = 349763628036266027723339106301
# #    nextPrice = 79156945126914824732836954
#     fee = 3000
#     liquidity = c[0][3]
#     amountRemaining = 10**18
#     print(currentPrice, nextPrice, fee, liquidity, amountRemaining)
#     print(computeSwapStep(currentPrice, nextPrice, liquidity, amountRemaining, fee)) #(price_next, amountIn, amountOut, feeAmount)


#     currentPrice = c[0][1]
# #    nextPrice = 349763628036266027723339106301
#     nextPrice = 79156945126914824732836954
#     fee = 3000
#     liquidity = c[0][3]
#     amountRemaining = 10**18
#     print(currentPrice, nextPrice, fee, liquidity, amountRemaining)
#     print(computeSwapStep(currentPrice, nextPrice, liquidity, amountRemaining, fee)) #(price_next, amountIn, amountOut, feeAmount)

    #    print(addrs)
 #   da = getPools_Ticks(addrs)
 #   print(da)
 
        # for i, p in enumerate(pools):
    #     addrs += [p['id']]
    #     for t in p['ticks']:
    #         print(t['tickIdx'])
    
    # q = u.forPools(addrs, ticks)
    # print(q)
    # for p in pools:
    #     print(p)
# d = u.forPools([yfi_eth],[ticks])
    # for p in d:
    #     for e in p:
    #         print(e)
    #    d = u.poolData(t)
#    print(d)
#    for i in d:
#        print(i)
    # s0 = d[0]
    # t0 = d[1][0]
    # t1 = d[1][1]
    # t2 = d[1][2]
    # tids = d[2]
    # print(s0)
    # print(t0)
    # print(t1)
    # print(t2)
    # print(tids)
