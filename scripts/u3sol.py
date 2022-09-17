import brownie
from brownie import accounts, TickTest, Contract, interface, QuoterV2, vyper_router 
#from brownie.network import priority_fee
import requests as r
import math
from collections import namedtuple
import json
import time
        
MAX_U256 = ((2**256) - 1)
MAX_U160 = ((2**160) - 1)
MIN_TICK = -887272
MAX_TICK = 887272
Q96 = 0x1000000000000000000000000
MAX_POOL_LENGTH = 100
YFI_ETH_V2_POOL = "0x2fdbadf3c4d5a8666bc06645b8358ab803996e28"

YFI_ETH_V3_POOL = "0x04916039b1f59d9745bf6e0a21f191d1e0a84287"
DAI_ETH_V3_POOL = "0x60594a405d53811d3BC4766596EFD80fd545A270"

YFI = "0x0bc529c00c6401aef6d220be8c6ea1667f6ad93e"
DAI = "0x6b175474e89094c44da98b954eedeac495271d0f"
WETH = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"

MIN_SQRT_PRICE = 4295128740
MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970341

DAI_WHALE = "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643"
WETH_WHALE = "0xf04a5cc80b1e94c69b48f5ee68a08cd2f09a7c3e"

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
        ratio = MAX_U256 // ratio

    if ratio % (1 << 32) == 0:
        p2 = 0
    else:
        p2 = 1
    sqrtPrice = (int(ratio) >> 32) + p2
    return int(sqrtPrice)

def shl(shift, num):
    return num << shift

def shr(shift, num):
    return num >> shift

def gt(n1, n2):
    if n1 > n2:
        return 1
    else:
        return 0


def getTickAtSqrt(price):
    ratio = price << 32
    r = ratio
    msb = 0

    f = shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
    msb = msb | f
    r = shr(f,r)

    f = shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
    msb = msb | f
    r = shr(f,r)

    f = shl(5, gt(r, 0xFFFFFFFF))
    msb = msb | f
    r = shr(f,r)

    f = shl(4, gt(r, 0xFFFF))
    msb = msb | f
    r = shr(f,r)

    f = shl(3, gt(r, 0xFF))
    msb = msb | f
    r = shr(f,r)

    f = shl(2, gt(r, 0xF))
    msb = msb | f
    r = shr(f,r)

    f = shl(1, gt(r, 0x3))
    msb = msb | f
    r = shr(f,r)

    f = gt(r, 0x1)
    msb = msb | f

    if msb >= 128:
        r = ratio >> (msb - 127)
    else:
        r = ratio << (127 - msb)

    log_2 = (msb - 128) << 64

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(63, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(62, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(61, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(60, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(59, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(58, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(57, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(56, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(55, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(54, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(53, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(52, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(51, f)
    r = shr(f,r)

    r = shr(127, (r*r))
    f = shr(128, r)
    log_2 = log_2 | shl(50, f)

    log_sqrt10001 = log_2 * 255738958999603826347141

    tickLow = (log_sqrt10001 - 3402992956809132418596140100660247210) >> 128
    tickHi = (log_sqrt10001 + 291339464771989622907027621153398088495) >> 128
    if tickLow == tickHi:
        return tickLow
    else:
        if getSqrtPriceFromTick(tickHi) <= price:
            return tickHi
        else:
            return tickLow

    
    
def do_request(query):
    req = r.post('https://api.thegraph.com/subgraphs/name/uniswap/uniswap-v3',json={'query':query})
    if req.status_code == 200:
        return req.json()
    else:
        raise Exception(f'Failed with return code {req.status_code, query}')
    

def getAllUni3Pools():
    uni3pools = []
    query1 = """
    {pools(first:1000,where:{liquidity_gt:0},orderBy:createdAtTimestamp,orderDirection:asc) { 
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
    ticks(first: 1000, where:{liquidityNet_gt: 0}, orderBy:tickIdx, orderDirection:asc){
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
        pool["pool_type"] = 1
        for tick in pool['ticks']:
            price = getSqrtPriceFromTick(tick['tickIdx'])
            tick['price'] = price
        uni3pools += [pool]
        #print(pool.keys())
    #print(uni3pools)
    lastTime = uni3pools[-1]['createdAtTimestamp']
    #print(lastTime)
    #print(uni3pools[-1]['id'])
    
    goOn = True
    while goOn:
        #last = len(uni3pools) - 1
        #lastTime = uni3pools[-1]['createdAtTimestamp']
        #print(lastTime)
#        print(uni3pools[-1])
        #print(len(uni3pools))
        #print(lastTime)
        #print(uni3pools[-1]['id'])
        query2_1 = """
        {pools (
            first:1000,
            orderBy:createdAtTimestamp,
            orderDirection:asc,
            where:{liquidity_gt:0, createdAtTimestamp_gt:
                   """
        query2_3 = """
            }){
        id,
        token0{id,symbol,decimals},
        token1{id,symbol,decimals},
        feeTier,
        createdAtBlockNumber,
        createdAtTimestamp,
        liquidity,
        sqrtPrice,
        token0Price,
        token1Price,
        tick,
        ticks(first: 1000, where:{liquidityNet_gt:0}, orderBy:tickIdx, orderDirection:asc){
            tickIdx,
            liquidityNet,
            liquidityGross,
            price0,
            price1
        }}}"""
        query = query2_1 + uni3pools[-1]['createdAtTimestamp'] + query2_3
        #print(query)
        requestN = do_request(query)
#        print(requestN)
#        print(requestN.keys())
        if requestN['data']['pools'] == []:
            #print(requestN)
            goOn = False
            break

        for pool in requestN['data']['pools']:
            pool["pool_type"] = 1
            for tick in pool['ticks']:
                price = getSqrtPriceFromTick(tick['tickIdx'])
                tick['price'] = price
            uni3pools += [pool]
            
        lastTime = uni3pools[-1]['createdAtTimestamp']
#        print(uni3pools[-1])
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

def mulmod(a, b, m):
    return (a*b)%m

def mulDiv(n1, n2, d):
    n1 = int(n1)
    n2 = int(n2)
    d = int(d)
    if d == 0:
        return 0
    else:
        return ((n1 * n2) // d)

def mulDivRoundingUp(n1, n2, d):
    n1 = int(n1)
    n2 = int(n2)
    d = int(d)
    if d == 0:
        return 0
    else:
        return ((n1*n2) // d) + 1

def divRoundingUp(n, d):
    n = int(n)
    d = int(d)
    if d == 0:
        return 0
    else:
        return n//d + 1

def addDelta(x, y):
    if y < 0:
        z = x + y
    else:
        z = x - y
    return z
    
def getAmount0Delta(priceA, priceB, liquidity, roundUp):
    if liquidity == 0:
        return 0
    if priceA > priceB:
        t = priceA
        priceA = priceB
        priceB = t
    numerator1 = int(liquidity) << 96
    numerator2 = priceB - priceA
    if roundUp:
        return divRoundingUp(mulDivRoundingUp(numerator1, numerator2, priceB), priceA)
    else:
        return mulDiv(numerator1, numerator2, priceB) // priceA
    
def getAmount1Delta(priceA, priceB, liquidity, roundUp):
    if liquidity == 0:
        return 0
    if priceA > priceB:
        t = priceA
        priceA = priceB
        priceB = t
    if roundUp:
        return mulDivRoundingUp(liquidity, (priceB - priceA), Q96)
    else:
        return mulDiv(liquidity, (priceB - priceA), Q96)

def amount0Delta(priceA, priceB, liquidity):
    if liquidity < 0:
        return -getAmount0Delta(priceA, priceB, abs(liquidity), False)
    else:
        return getAmount0Delta(priceA, priceB, abs(liquidity), True)
    
def amount1Delta(priceA, priceB, liquidity):
    if liquidity < 0:
        return -getAmount1Delta(priceA, priceB, abs(liquidity), False)
    else:
        return getAmount1Delta(priceA, priceB, abs(liquidity), True)

def ticksAndAddr(pool):
    address = pool['id']
    ticks = []
    for tick in pool['ticks']:
        ticks += [int(tick['tickIdx'])]
    return (address, ticks)

def getNextPriceFromAmount0RoundingUp(price, liquidity, amount, add):
    if amount == 0:
        return price
    numerator1 = liquidity << 96
    if add:
        product = amount * price
        if (product // amount) == price:
            denominator = numerator1 + product
            if denominator >= numerator1:
                return mulDivRoundingUp(numerator1, price, denominator)
        return divRoundingUp(numerator1, ((numerator1 // price) + amount))
    else:
        denominator = numerator1 - (amount * price)
        return mulDivRoundingUp(numerator1, price, denominator)

#issue leads here?
def getNextPriceFromAmount1RoundingDown(price, liquidity, amount, add):
    if add:
        if amount <= MAX_U160:
            quotient = (int(amount) << 96) // liquidity
        else:
            quotient = mulDiv(amount, Q96, liquidity)
        return price + quotient
    else:
        if amount <= MAX_U160:
            quotient = divRoundingUp(amount << 96, liquidity)
        else:
            quotient = mulDivRoundingUp(amount, Q96, liquidity)
        assert price > quotient
        return price - quotient
        
#issue here?                
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
    zeroForOne = (price_current >= price_target)
    exactIn = (amount_remaining >= 0)
    #print(zeroForOne)
    if amount_remaining < 0:
        amount_remaining = abs(amount_remaining)
    if liquidity == 0:
        price_next = 0
        amountIn = 0
        amountOut = 0
        feeAmount = 0
        return (price_current, amountIn, amountOut, feeAmount)
#    print("price_targetss", price_target)
#    print("price_currentss", price_current)
#    print(price_current >= price_target)
#    print("zf1",zeroForOne)
#    print("exactIn", exactIn)
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
#        print("amountIn", amountIn)
    else:
        if zeroForOne:
            amountOut = getAmount1Delta(price_target, price_current, liquidity, False)
        else:
            amountOut = getAmount0Delta(price_current, price_target, liquidity, False)
        if amount_remaining >= amountOut:
            price_next = price_target
        else:
            price_next = getNextPriceFromOutput(price_current, liquidity, amount_remaining, zeroForOne)
#        print("amountOut", amountOut)
#    print("price_next",price_next)
    is_max = price_target == price_next
#    print("2 pn, pt", price_next, price_target)
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
#    print("amountIn", amountIn)
#    print("amountOut", amountOut)
#    print("")
    if not exactIn and (amountOut > amount_remaining):
        amountOut = amount_remaining
#    print("1 pn, pt", price_next, price_target)
    if exactIn and (price_next != price_target):
        feeAmount = amount_remaining - amountIn
    else:
        feeAmount = mulDivRoundingUp(amountIn, feePips, ((10**6) - feePips))
    return (price_next, amountIn, amountOut, feeAmount)
#def index_of_tick(tick_Array, target):



StepComputations = namedtuple('Stepcomputations', ["price_start", "tick_next", "price_next_tick", "amount_in", "amount_out", "fee_amount"])
SwapState = namedtuple('Swapstate', ["amount_remaining", "amount_calculated", "price_current", "tick_current", "liquidity", "index_next_tick"])


# def v3swapExactIn(uni3pool, tokenIn, tokenOut, initialAmountIn):
#     pool_addr = uni3pool['id']
#     feePips = uni3pool['feeTier']
#     token0 = uni3pool['token0']['id']
#     token1 = uni3pool['token1']['id']


#     if (tokenIn == token0 or tokenIn == token1) and (tokenOut == token0 or tokenOut == token1):
#         if tokenIn == token0:
#             zeroForOne = True
#         else:
#             zeroForOne = False
#     else:
#         return "these tokens arnt in this pool"
#     #print(zeroForOne)
#     current_tick = int(uni3pool['tick'])
#     for i, tick in enumerate(uni3pool['ticks']):
#         if current_tick > int(tick['tickIdx']):
#             prev_i = i
#             prev_tick = tick
#         else: 
#             if zeroForOne:
#                 #price_next_tick = prev_tick['price']
#                 index = prev_i
#             else:
#                 #price_next_tick = tick['price']
#                 index = i
#             break

        
#     out = 0
#     ticksCrossed = 0
#     length = len(uni3pool['ticks'])
#     state = SwapState(initialAmountIn, 0, int(uni3pool['sqrtPrice']), int(uni3pool['tick']), uni3pool['liquidity'], index)
#     while state.amount_remaining != 0:

#         if zeroForOne:
#             if (index - ticksCrossed) < 0:
#                 tickIndex = 0
#             else:
#                 tickIndex = index - ticksCrossed

#         else:
#             if (index + ticksCrossed) > (length - 1):
#                 tickIndex = (length - 1)
#             else:
#                 tickIndex = index + ticksCrossed
#         step = StepComputations(0,0,0,0,0,0)

#         step.price_start = state.price_current

#         step.tick_next = uni3pool['ticks'][tickIndex]['tickIdx'] 
        
#         step.price_next_tick = step.tick_next['price']

#         state.price_current, step.amount_in, step.amount_out, step.fee_amount = computeSwapStep(state.price_current, step.price_next_tick, state.liquidity, state.amount_remaining, feePips)
        
#         state.amount_remaining -= (step.amount_in + step.fee_amount)
#         state.amount_calculated -= step.amount_out 

#         if state.price_current == step.price_next_tick:
#             if zeroForOne:
#                 liquidityNet = -int(uni3pool['ticks'][tickIndex]['liquidityNet'])

#             else:
#                 liquidityNet = int(uni3pool['ticks'][tickIndex]['liquidityNet'])
#             state.liquidity = addDelta(state.liquidity, liquidityNet)
#             ticksCrossed += 1
# #            print("crossed tick")
#         elif state.price_current != step.price_start:
#             state.tick = getTickAtSqrt(state.price_current)


#     if zeroForOne:
#         amount0 = initialAmountIn - state.amount_remaining 
#         amount1 = state.amount_calculated
#     else:
#         amount0 = state.amount_calculated
#         amount1 = initialAmountIn - state.amount_remaining
#     return amount0, amount1




def v3swapExactIn(uni3pool, tokenIn, tokenOut, initialAmountIn):
    pool_addr = uni3pool['id']
    price_current = uni3pool['sqrtPrice']
    amount_remaining = initialAmountIn
    feePips = uni3pool['feeTier']
    liquidity = int(uni3pool['liquidity'])
    token0 = uni3pool['token0']['id']
    token1 = uni3pool['token1']['id']
    debug = False

    if debug:
        print(pool_addr)
        
    if (tokenIn == token0 or tokenIn == token1) and (tokenOut == token0 or tokenOut == token1):
        if tokenIn == token0:
            zeroForOne = True
        else:
            zeroForOne = False
    else:
        return "these tokens arnt in this pool"
    #print(zeroForOne)
    current_tick = int(uni3pool['tick'])
    index = 0
    prev_i = 0
    for i, tick in enumerate(uni3pool['ticks']):
        if current_tick > int(tick['tickIdx']):
            prev_i = i
            prev_tick = tick
        else: 
            if zeroForOne:
                #price_next_tick = prev_tick['price']
                index = prev_i
            else:
                #price_next_tick = tick['price']
                index = i
            break

        
    out = 0
    ticksCrossed = 0
    length = len(uni3pool['ticks'])
#    amount_calculated = 0
#    print("amount remaining",amount_remaining)
#    print("start tick", current_tick)
#    print("")
    count = 0
    while amount_remaining != 0 or count < 1000:
        price_start = price_current
        if zeroForOne:
            if (index - ticksCrossed) < 0:
                tickIndex = 0
            else:
                tickIndex = index - ticksCrossed

        else:
            if (index + ticksCrossed) > (length - 1):
                tickIndex = (length - 1)
            else:
                tickIndex = index + ticksCrossed

        tick_next = uni3pool['ticks'][tickIndex]
        price_next_tick = tick_next['price']

        price_current, amountIn, amountOut, feeAmount  = computeSwapStep(price_current, price_next_tick, liquidity, amount_remaining, feePips)
        amount_remaining -= (amountIn + feeAmount)
        #amount_calculated -= amountOut
        out += amountOut
        #print("remaining",amount_remaining)
        # if amount_remaining <= 0:
        #     print("")
        #     print("numbers at amount_remaining <= 0")
        #     print("price_current", price_current)
        #     print("liquidity", liquidity)
        #     print("tick", uni3pool['ticks'][tickIndex]['tickIdx'])
        #     print("calculated tick price_current", getTickAtSqrt(price_current))
        #     print("liquidity", liquidity)
        #     break
        #price_current = price_next

        if price_current == price_next_tick:
            if zeroForOne:
                liquidityNet = -int(tick_next['liquidityNet'])

            else:
                liquidityNet = int(tick_next['liquidityNet'])
            liquidity = addDelta(liquidity, liquidityNet)
            ticksCrossed += 1
        count += 1
        # elif price_current != price_start:
        #     tick_next = tickFromPrice(price_current)
            
            
            #tick_current = getTickAtSqrt(price_current)
            #price_current = getSqrtPriceFromTick(tick_current)
            # print("liquidityNet", liquidityNet)
            # print("liquidity", liquidity)
            
            # print("crossed tick")
            # print("")

            

#            print("liquidity", liquidity)
#            print("liquidityNet", liquidityNet)
    # if zeroForOne:
    #     amount0 = initialAmountIn - amount_remaining
    #     amount1 = amount_calculated

    # else:
    #     amount0 = amount_calculated
    #     amount1 = initialAmountIn - amount_remaining
            
        
    return out#, amount0, amount1

def diffinator(ar1, ar2):
    diff = []
    assert len(ar1) == len(ar2)
    for i in range(len(ar1) - 1):
        diff += [ar1[i] - ar2[i]]
    return diff


def test_stuff(uni3pools,n,a):
    t = TickTest.deploy({"from": accounts[0]})
#    for i in range(len(uni3pools)):
    for i in range(1):
        print("............................................")
        print("token0", uni3pools[i]['token0']['symbol'])
        print("token1", uni3pools[i]['token1']['symbol'])
        print("pool address", uni3pools[i]['id'])
        
        currentPrice = int(uni3pools[i]['sqrtPrice'])
        targetUp = getSqrtPriceFromTick(uni3pools[i]['ticks'][-1]['tickIdx'])
        targetDown = getSqrtPriceFromTick(uni3pools[i]['ticks'][0]['tickIdx'])
        liquidity = int(uni3pools[i]['liquidity'])
        token0decimals = int(uni3pools[i]['token0']['decimals'])
        token1decimals = int(uni3pools[i]['token1']['decimals'])
        amountUp = a*10**n
        amountDown = a*10**n
        print("liquidity", liquidity)
        print("current price", currentPrice)
        print("amountIn going up",amountUp)
        print("amountIn going down",amountDown)
        fee = uni3pools[i]['feeTier']
        testUp = t.swapStep(currentPrice, targetUp, liquidity, amountUp, fee)
        myUp = computeSwapStep(currentPrice, targetUp, liquidity, amountUp, fee)
        testDown = t.swapStep(currentPrice, targetDown, liquidity, amountDown, fee)
        myDown = computeSwapStep(currentPrice, targetDown, liquidity, amountDown, fee)
        testUpExactOut = t.swapStep(currentPrice, targetUp, liquidity, -amountUp, fee)
        myUpexactOut = computeSwapStep(currentPrice, targetUp, liquidity, -amountUp, fee)
        testDownExactOut = t.swapStep(currentPrice, targetDown, liquidity, -amountDown, fee)
        myDownexactOut = computeSwapStep(currentPrice, targetDown, liquidity, -amountDown, fee)
        print("testing computeswapstep")
        print("up", testUp)
        print("up", myUp)
        print("diff", (testUp[0] - myUp[0]), (testUp[1] - myUp[1]), (testUp[2] - myUp[2]), (testUp[3] - myUp[3]))
        print("")
        print("down", testDown)
        print("down", myDown)
        print("diff", (testDown[0] - myDown[0]), (testDown[1] - myDown[1]), (testDown[2] - myDown[2]), (testDown[3] - myDown[3]))
        print("")
        print("exactOut up", testUpExactOut)
        print("exactOut up", myUpexactOut)
        print("diff", diffinator(testUpExactOut, myUpexactOut))
        print("")
        print("exactOut down", testDownExactOut)
        print("exactOut down", myDownexactOut)
        print("diff", diffinator(testDownExactOut, myDownexactOut))
        print("")
        print("nextPrice, amountIn, amountOut, feeAmount")
        print("-------------------------------------------------------------")
        print("")
        print("testing amountNDelta")
        print("amount in")
        
        tzf1 = t.amount0Delta(targetUp, currentPrice, liquidity)
        mzf1 = amount0Delta(targetUp, currentPrice, liquidity)
        print("amount0 zeroforone", tzf1)
        print("amount0 zeroforone", mzf1)
        print("diff", (tzf1 - mzf1))
        print("")
        
        t1fz = t.amount1Delta(currentPrice, targetDown,liquidity)
        m1fz = amount1Delta(currentPrice, targetDown,liquidity)
        print("amount1 oneforzero", t1fz)
        print("amount1 oneforzero", m1fz)
        print("diff", (t1fz - m1fz))
        print("")
        
        tzf1 = t.amount0Delta(targetUp, currentPrice, -liquidity)
        mzf1 = amount0Delta(targetUp, currentPrice, -liquidity)
        print("amount0 zeroforone", tzf1)
        print("amount0 zeroforone", mzf1)
        print("diff", (tzf1 - mzf1))
        print("")
        
        t1fz = t.amount1Delta(targetDown, currentPrice, -liquidity)
        m1fz = amount1Delta(targetDown, currentPrice, -liquidity)
        print("amount1 oneforzero", t1fz)
        print("amount1 oneforzero", m1fz)
        print("diff", (t1fz - m1fz))
        print("")
        print("amount out")
        
        tzf1 = t.amount1Delta(targetDown, currentPrice, liquidity)
        mzf1 = amount1Delta(targetDown, currentPrice, liquidity)
        print("amount1 zeroforone", tzf1)
        print("amount1 zeroforone", mzf1)
        print("diff", (tzf1 - mzf1))
        
        t1fz = t.amount0Delta(currentPrice, targetUp, liquidity)
        m1fz = amount0Delta(currentPrice, targetUp, liquidity)
        print("amount0 zeroforone", t1fz)
        print("amount0 zeroforone", m1fz)
        print("diff", (t1fz - m1fz))

        print("-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-")
        print("")
        print("testing get next price from input/output")
        print("zeroforone")
        y = t.sqrtPriceFromOutput(currentPrice, liquidity, amountUp, True)
        m = getNextPriceFromOutput(currentPrice, liquidity, amountUp, True)
        print("diff", (y-m))
        #bad
        y = t.sqrtPriceFromInput(currentPrice, liquidity, amountUp, True)
        m = getNextPriceFromInput(currentPrice, liquidity, amountUp, True)
        print("diff", (y-m))
        print("oneforzero")
        y = t.sqrtPriceFromOutput(currentPrice, liquidity, amountUp, False)
        m = getNextPriceFromOutput(currentPrice, liquidity, amountUp, False)
        print("diff", (y-m))
        #bad
        y = t.sqrtPriceFromInput(currentPrice, liquidity, amountUp, False)
        m = getNextPriceFromInput(currentPrice, liquidity, amountUp, False)
        print("diff", (y-m))

def tick_check(uni3pool):
    c = TickTest.deploy({"from": accounts[0]})
    #print(uni3pool['id'])
    for t in uni3pool['ticks']:
         r = c.check_ticks(uni3pool['id'], t['tickIdx'])
         if (t['liquidityNet'] == r[1]) and (r[-1] == True):
             print("looking good")
         else:
             print("BAD!", t, r)
             
def swap_test(uni3pool,n,a):
    c = TickTest.deploy({"from": accounts[0]})
    WETH_WHALE = "0x8EB8a3b98659Cce290402893d0123abb75E3ab28"
    weth = Contract("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
    #print(weth.balanceOf(c.address))
    weth.transferFrom(WETH_WHALE, c.address, (a*10**n), {"from": WETH_WHALE})
    bal = weth.balanceOf(c.address)
    #print(bal)
    c.approveToken(weth.address, uni3pool['id'], {"from": accounts[0]})
    s0_pre = c.get_s0(uni3pool['id'])
    liquidity_pre = c.get_liquidity(uni3pool['id'])
    c.swapExactIn(uni3pool['id'], uni3pool['token1']['id'], uni3pool['token0']['id'], bal, False, {"from": accounts[0]})
    uni = interface.ERC20("0x1f9840a85d5af5bf1d1762f925bdaddc4201f984")
    uni_bal = uni.balanceOf(c.address)
    print("")
    print("real numbers")
    print("amount out  price  tick  price_post  tick_post  liquidity  liquidity_post")
    s0 = c.get_s0(uni3pool['id'])
    print(uni_bal)
    print(s0_pre[0])
    print(s0_pre[1])
    print(s0[0])
    print(s0[1])
    print(liquidity_pre)
    print(c.get_liquidity(uni3pool['id']))          
    return (uni_bal, s0[1])


def swap_test_uniToWeth(uni3pool,n,a):
    c = TickTest.deploy({"from": accounts[0]})
    UNI_WHALE = "0x47173b170c64d16393a52e6c480b3ad8c302ba1e"
    uni = interface.ERC20("0x1f9840a85d5af5bf1d1762f925bdaddc4201f984")    
    print(uni.balanceOf(c.address))
    uni.transferFrom(UNI_WHALE, c.address, (a*10**n), {"from": UNI_WHALE})
    uni_bal = uni.balanceOf(c.address)
    print(uni_bal)
    c.approveToken(uni.address, uni3pool['id'], {"from": accounts[0]})
    c.swapExactIn(uni3pool['id'], uni3pool['token0']['id'], uni3pool['token1']['id'], uni_bal, True, {"from": accounts[0]})

    weth = interface.ERC20("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")

    bal = weth.balanceOf(c.address)
    print("real         amount out",bal)
    s0 = c.get_s0(uni3pool['id'])
    print("real s0",s0[0], s0[1])
    print("real liquidity", c.get_liquidity(uni3pool['id']))
    return bal

def percent_error(calc, real):
    return ((calc - real) / real) * 100

def quote_exactInSinglePool_oneForZero(uni3pool,n,a):
    q = QuoterV2.deploy("0x1F98431c8aD98523631AE4a59f267346ea31F984", "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", {"from": accounts[0]})
    tokenIn = uni3pool['token1']['id']
    tokenOut = uni3pool['token0']['id']
    amountIn = a*10**n
    fee = uni3pool['feeTier']
    priceLimit = uni3pool['ticks'][-1]['price']
    r = q.quoteExactInputSingle((tokenIn, tokenOut, amountIn, fee, priceLimit), {"from": accounts[0]})
    print(r)

def testTick(uni3pool):
    c = TickTest.deploy({"from": accounts[0]})
    my_tick = getTickAtSqrt(int(uni3pool['sqrtPrice']))
    real_tick = c.tickFromPrice(uni3pool['sqrtPrice'])
    actual_tick = uni3pool['tick']
    print(my_tick, real_tick, actual_tick)

def test_nextTick(uni3pool):
    c = TickTest.deploy({"from": accounts[0]})

    current_tick = int(uni3pool['tick'])
    for i, tick in enumerate(uni3pool['ticks']):
        if current_tick > int(tick['tickIdx']):
            prev_i = i
            prev_tick = tick
        else: 
            index_left = prev_i
            index_right = i
            break
    lefttick = c.nextInitializedTickWithinOneWord(uni3pool['id'], uni3pool['tick'], True)
    righttick = c.nextInitializedTickWithinOneWord(uni3pool['id'], uni3pool['tick'], False)
    print("left  ", lefttick)
    print("right ", righttick)
    print("cleft ", uni3pool['ticks'][index_left]['tickIdx'])
    print("cright", uni3pool['ticks'][index_right]['tickIdx'])

def test_mulDiv(n1, n2, d):
    c = TickTest.deploy({"from": accounts[0]})
    r = c.mulDiv(n1,n2,d)
    m = mulDiv(n1,n2,d)
    print("")
    print("mul div test")
    print(r)
    print(m)
    print(f"percent error {percent_error(m, r)}%")
    print("")

def get_token_from_whale(Token_addr, whale_addr, amount, recipient):
    token = Contract(Token_addr)
    print(f"{recipient} balance for {Token_addr} | {token.balanceOf(recipient)}")
    token.transferFrom(whale_addr, recipient, amount, {"from": whale_addr})
    print(f"{recipient} balance for {Token_addr} | {token.balanceOf(recipient)}")


def test_v3_two_hops():
    r = Router.deploy({"from": accounts[0]})
    get_token_from_whale(DAI, DAI_WHALE, Contract(DAI).balanceOf(DAI_WHALE), accounts[0])
    pool_type = 1
    pool = DAI_ETH_V3_POOL
    token0 = DAI
    token1 = WETH
    amountIn = 0
    amountOut = 0
    zeroForOne = True
    amountSpecified = Contract(DAI).balanceOf(accounts[0])
    sqrtPriceLimit = MIN_SQRT_PRICE


    params1= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)


    pool_type = 1
    pool = YFI_ETH_V3_POOL
    token0 = YFI
    token1 = WETH
    amountIn = 0
    amountOut = 0
    zeroForOne = False
    amountSpecified = (10**18)
    sqrtPriceLimit = MAX_SQRT_PRICE

    
    params2= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)
    
    params = [params1, params2]


    Contract(WETH).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    Contract(DAI).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    r.swapAlongPath(params, {"from": accounts[0]})
    
def univ2_getAmountOut(amountIn, _pool, tokenIn):
    pool = interface.IUniswapV2Pair(_pool)
    token0 = pool.token0()
    token1 = pool.token1()
    reserves = pool.getReserves()
    if tokenIn == token0:
        reserveOut = reserves[1]
        reserveIn = reserves[0]
    elif tokenIn == token1:
        reserveOut = reserves[0]
        reserveIn = reserves[1]
    amountInWithFee = amountIn * 977
    numerator = amountInWithFee * reserveOut
    denominator = (reserveIn * 1000) + amountInWithFee
    return numerator // denominator
    
    
def test_v2_v3():
    r = Router.deploy({"from": accounts[0]})
    token = WETH
    whale = WETH_WHALE
    get_token_from_whale(token, whale, Contract(token).balanceOf(whale), accounts[0])    
    
    pool_type = 0
    pool = YFI_ETH_V2_POOL
    token0 = YFI
    token1 = WETH
    amountIn = (10**19)
    amountOut = univ2_getAmountOut(amountIn, pool, token)
    zeroForOne = False
    amountSpecified = 0
    sqrtPriceLimit = 0


    params1= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)


    
    pool_type = 1
    pool = YFI_ETH_V3_POOL
    token0 = YFI
    token1 = WETH
    amountIn = 0
    amountOut = 0
    zeroForOne = True
    amountSpecified = (10**18)
    sqrtPriceLimit = MIN_SQRT_PRICE

    params2= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)

    Contract(WETH).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    Contract(YFI).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    
    params = [params1, params2]
    r.swapAlongPath(params, {"from": accounts[0]})

def save_uni3_data():
    uni3pools = getAllUni3Pools()
    f = open("uni3_data.txt", "w")
    f.write(json.dumps(uni3pools))
    f.close()

def load_uni3_data():
    f = open("uni3_data.txt")
    info = json.load(f)
    f.close()
    return info

# def pools_for_token(token, uni3pools, uni2pools):
#     pools = []
#     for pool in uni3pools:
#         if (pool['token0']['id'] == token) or (pool['token1']['id'] == token):
#             pools += [pool['id']]
#     for pool in uni2pools:
#         if (pool['token0']['id'] == token) or (pool['token1']['id'] == token):
#             pools += [pool['id']]
#     token_to_pools = {}
#     token_to_pools[token] = pools

def token_to_pools(uni3pools):
    ttp = {}
    for p in uni3pools:
        pool = p['id']
        token0 = p['token0']['id']
        token1 = p['token1']['id']

        
        
        if token0 in ttp:
            if pool not in ttp[token0]:
                ttp[token0] += [pool]
        else:
            ttp[token0] = [pool]

        if token1 in ttp:
            if pool not in ttp[token1]:
                ttp[token1] += [pool]
        else:
            ttp[token1] = [pool]

    return ttp

def pool_to_data(uni3pools):
    d = {}
    for pool in uni3pools:
          d[pool['id']] = pool
    return d

def find_next_market_and_next_token(pools_already_done, curent_token, token_to_pool_dic, pooldata):
    potential_pools = token_to_pool_dic[curent_token]
    next_pool = ""
    next_token = ""
    for pool in potential_pools:
        if pool not in pools_already_done:
            next_pool = pool
            if curent_token == pooldata[pool]['token0']['id']:
                next_token = pooldata[pool]['token1']['id']
            if curent_token == pooldata[pool]['token1']['id']:
                next_token = pooldata[pool]['token0']['id']
            break
    return next_pool, next_token
    
    

def token_out(tokenIn, pooladdr, pooldata):
    token0 = pooldata[pooladdr]['token0']['id']
    token1 = pooldata[pooladdr]['token1']['id']

    if tokenIn == token0:
        return token1
    if tokenIn == token1:
        return token0

def calc_zeroForOne(tokenIn, pool):
    if tokenIn == pool["token0"]['id']:
        return True
    else:
        return False

def calc_spl(zf1):
    if zf1:
        return MIN_SQRT_PRICE
    else:
        return MAX_SQRT_PRICE
    
def _calc_params(path_of_pool_addr, start_token, pooldata):
    params = []
    tokenIn = start_token
    
    for pool in path_of_pool_addr:
        pp = []
        tokenOut = token_out(tokenIn, pool, pooldata)
        zf1 = calc_zeroForOne(tokenIn, pooldata[pool])
        spl = calc_spl(zf1)
        pp += [{
            "pool_type": pooldata[pool]["pool_type"],
            "pool": pool,
            "token0": pooldata[pool]['token0']['id'],
            "token1": pooldata[pool]['token1']['id'],
            "amountIn": 0,
            "amountOut": 0,
            "zeroForOne": zf1,
            "amountSpecified": 0,
            "sqrtPriceLimit": spl
        }]
#        params += [{"pool_address": pool, "tokenIn": tokenIn, "tokenOut": tokenOut}]
        params += [pp]
        tokenIn = tokenOut
    return params
    
def searcher(first_token, target_token, current_token, loops, used_pools, token_to_pools, pooldata): 
    next_pool, next_token = find_next_market_and_next_token(used_pools, current_token, token_to_pools, pooldata)
    used_pools += [next_pool]
    if next_pool != "" and next_token != "":
        if next_token == target_token:
            if target_token not in loops:
                loops[target_token] = [_calc_params(used_pools, first_token, pooldata)]
            else:
                params = _calc_params(used_pools, first_token, pooldata)
                if params not in loops[target_token]:
                    loops[target_token] += [params]
        else:
            if len(used_pools) < MAX_POOL_LENGTH:
                searcher(first_token, target_token, next_token, loops, used_pools, token_to_pools, pooldata)
    else:
        pass

 #recusion is better and is working           
def path_search(token_to_pools, pooldata):
    loops = {}
    for token, pools in token_to_pools.items():
        for pool in pools:
            tokenOut = token_out(token, pool, pooldata)
            used_pools = []
            used_pools += [pool]
            searcher(token, token, tokenOut, loops, used_pools, token_to_pools, pooldata)
    return loops

def path_finder(start_token, end_token, token_to_pools, pooldata):
    loops = {}
    pools = token_to_pools[start_token]
    for pool in pools:
        tokenOut = token_out(start_token, pool, pooldata)
        used_pools = []
        used_pools += [pool]
        if tokenOut == end_token:
            if end_token not in loops:
                loops[end_token] = [_calc_params(used_pools, start_token, pooldata)]
            else:
                params = _calc_params(used_pools, start_token, pooldata)
                if params not in loops[end_token]:
                    loops[end_token] += [params]
        else:
            searcher(start_token, end_token, tokenOut, loops, used_pools, token_to_pools, pooldata)
    return loops[end_token]

def save_paths():
    uni3pools = load_uni3_data()
    token_to_pool_dic = token_to_pools(uni3pools)
    pool_to_data_dic = pool_to_data(uni3pools)
    paths = find_paths(token_to_pool_dic, pool_to_data_dic)
    f = open("paths.txt", "w")
    f.write(json.dumps(paths))
    f.close()

def load_paths():
    f = open("paths.txt")
    info = json.load(f)
    f.close()
    return info

def swaploop(loops, pooldata, initialIn):
    profit = {}
    for token, paths in loops.items():
        for path in paths:
            tokenIn = token
            tokenOut = token_out(tokenIn, path[0], pooldata)
            amountIn = initialIn
            for k, pool in enumerate(path):
                outputAmount = v3swapExactIn(pooldata[pool], tokenIn, tokenOut, amountIn)
                tokenIn = tokenOut
                try:
                    tokenOut = token_out(tokenIn, path[k + 1], pooldata)
                except IndexError:
                    if token not in profit:
                        profit[token] = [outputAmount - initialIn]
                    else:
                        profit[token] += [outputAmount - initialIn]
                    print(outputAmount - initialIn)
                    print(path)
                    print("")
                    
                amountIn = outputAmount


def starting_ending_token_test(_paths, pooldata):
    for token, paths in _paths.items():
        for path in paths:
            for pool in path[0]:
                start_pool = pool
            for pool in path[-1]:
                end_pool = pool
            start_pool_token0 = pooldata[start_pool]['token0']['id']
            start_pool_token1 = pooldata[start_pool]['token1']['id']
            end_pool_token0 = pooldata[end_pool]['token0']['id']
            end_pool_token1 = pooldata[end_pool]['token1']['id']
            if (start_pool_token0 == end_pool_token0 or start_pool_token0 == end_pool_token1) or (start_pool_token1 == end_pool_token0 or start_pool_token1 == end_pool_token1):
                pass
            else:
                print(token, path, "bad")


                
def path_info_and_checks(paths, pooldata):
    starting_ending_token_test(paths, pooldata)

    loopcount = 0
    looplen = 0
    for k,v in paths.items():
        print("")
        print(k)
        for l in v:
            loopcount += 1
            looplen += len(l)
        avelooplen = looplen / loopcount
        print(avelooplen)
        avelooplen = 0
    print(loopcount)
    
    
def openfileasjson(name):
    f = open(name)
    info = json.load(f)
    f.close()
    return info

def saveasjson(name, data):
    f = open(name, "w")
    f.write(json.dumps(data))
    f.close()

def token_to_markets(allThePools):
    ttp = {}
    for protocol in allThePools:
        #print(len(protocol))
        if type(protocol) is dict:
            for addr, pool in protocol.items():
                token0 = pool['token0']['id']
                token1 = pool['token1']['id']

                if token0 in ttp:
                    if addr not in ttp[token0]:
                        ttp[token0] += [addr]
                else:
                    ttp[token0] = [addr]

                if token1 in ttp:
                    if addr not in ttp[token1]:
                        ttp[token1] += [addr]
                else:
                    ttp[token1] = [addr]
        else:
            for pool in protocol:
                addr = pool['id']
                token0 = pool['token0']['id']
                token1 = pool['token1']['id']
                
                if token0 in ttp:
                    if addr not in ttp[token0]:
                        ttp[token0] += [addr]
                else:
                    ttp[token0] = [addr]

                if token1 in ttp:
                    if addr not in ttp[token1]:
                        ttp[token1] += [addr]
                else:
                    ttp[token1] = [addr]
    return ttp

def pool_to_params(allThePools):
    d = {}
    for protocol in allThePools:
        for pool in protocol:
            d[pool['id']] = pool
    return d

def add_pool_params(pools, filename, poolType):
    # for pool in pools:
    #     pool["pool_type"] = poolType
    # saveasjson(filename, pools)
    for pool in pools:
        pools[pool]["pool_type"] = poolType
    saveasjson(filename, pools)

def dta(filename, data):
    a = []
    for key, value in data.items():
        a += [value]
    saveasjson(filename, a)

def pool_type_check(pooldata):
    for pool, data in pooldata.items():
        try:
            data['pool_type']
        except KeyError:
            print(data)

def make_lower(pools):
    p = []
    for pool in pools:
        pool['id'] = pool['id'].lower()
        pool['token0']['id'] = pool['token0']['id'].lower()
        pool['token1']['id'] = pool['token1']['id'].lower()
        p += [pool]
    return p

# def check_path_reserves(path, pooldata):
#     potential_paths = []
#     for step in path:
#         for pool in step:
#             addr = pool
#         if step['pool_type'] == 0:
#             reserve0 = pooldata[addr]['token0']['reserves']
#             reserve1 = pooldata[addr]['token1']['reserves']
#             if reserve0 > 1000 and reserve1 > 1000:
#                 potential_path = True
#             else:
#                 potential_path = false
#         elif step['pool_type'] == 1:





def path_len_dis(paths):
    r = {}
    for path in paths:
        path_len = len(path)
        if path_len not in r:
            r[path_len] = 1
        else:
            r[path_len] += 1
    return r

def symbol_to_address(uni3pools):
    book = {}
    for pool in uni3pools:
        
        s0 = pool['token0']['symbol'].lower()
        s1 = pool['token1']['symbol'].lower()
        if s0 not in book:
            book[s0] = pool['token0']['id']
        if s1 not in book:
            book[s1] = pool['token1']['id']
    return book
YFI_WHALE = "0xfeb4acf3df3cdea7399794d0869ef76a6efaff52"
def get_token_from_whale(Token_addr, whale_addr, amount, recipient):
    token = Contract(Token_addr)
    print(f"{recipient} balance for {Token_addr} | {token.balanceOf(recipient)}")
    token.transfer(recipient, amount, {"from": whale_addr})
    print(f"{recipient} balance for {Token_addr} | {token.balanceOf(recipient)}")


def _swapper(paths):
    r = vyper_router.deploy({"from": accounts[0]})
    get_token_from_whale(YFI, YFI_WHALE, (10**20), accounts[0])
    Contract(start_token).approve(r.address, (2**256) - 1, {"from": accounts[0]}) 
    for path in paths:
        rp = path_to_router_path(path)
        if rp[0][0] == 1:
            g = list(rp[0])
            g[4] = 10000
            rp[0] = tuple(g)
                    
        else:
            g = list(rp[0])
            g[7] = 10000
            rp[0] = tuple(g)
            
        print(rp[0])
        r.swap_along_path(rp, start_token, end_token, accounts[0], {"from": accounts[0]})


def pathnswap(paths):
    #router = vyper_router.deploy({"from": accounts[0]})
    tt = TickTest.deploy({"from": accounts[0]})
    #get_token_from_whale(WETH, WETH_WHALE, Contract(WETH).balanceOf(WETH_WHALE), accounts[0])
    #Contract(WETH).approve(router.address, (2**256) - 1, {"from": accounts[0]})
    paths = sorted(paths, key=len)
    for path in paths:
        #print(path[0][0])
        if path[0][0]["pool_type"] == 0:
            path[0][0]["amountIn"] = 10**17
        else:
            path[0][0]["amountSpecified"] = 10**17
        #print(path)
        try:
            print(".....................................")
            #print("")
            #print(path)
            #print(path_to_router_path(path))
            #prebal = Contract(WETH).balanceOf(accounts[0])
            calced = tt.check_path(path_to_router_path(path))
            #router.swap_along_path(calced, WETH, WETH, accounts[0], {"from": accounts[0]})
            #postbal = Contract(WETH).balanceOf(accounts[0])
            #diff = (postbal - prebal) * 10**-18
            #print(diff)
            if calced[0][0] == 0:
                amountIn = calced[0][4]
            else:
                amountIn = calced[0][7]
            amountOut = calced[-1][5]
            diff = amountOut - amountIn
            print(diff * 10**-18)
            
            if diff > 0:
                print(calced)
            #print(calced)
            #print("")
            #for pool in calced:
                #print(pool)
                # print("")
            print("-------------------------------------")
        except:
#            time.sleep(.017)
        #router.swap_along_path(calced, YFI, YFI, accounts[3], {"from": accounts[0]})
            pass
    

    
    
def path_cli():
    name_to_address = openfileasjson("book.txt")
    pooldata = openfileasjson("pooldata.txt")
    token_to_pools = openfileasjson("token_to_pools.txt")
    while True:
        start_token = ""
        while start_token == "":
            try:
                start_token = name_to_address[str(input("start token: "))]
            except KeyError:
                pass

        end_token = ""
        while end_token == "":
            try:
                end_token = name_to_address[str(input("end token: "))]
            except KeyError:
                pass

        print("paths")
        start = time.time()
        paths = path_finder(start_token, end_token, token_to_pools, pooldata)
        end = time.time()
        #for path in paths:
            # if len(path) >= 10:
            #     print(len(path)
            #print(path)
            #print("")
        print(f"took: {end - start}")
        print("number of paths",len(paths))
        for k, v in sorted(path_len_dis(paths).items()):
            print(k, v)
        if str(input("print? ")) == "":
            for path in paths:
                print(path_to_router_path(path))
                # for pool in path:
                #     print(pool)
                print("")
        print("")
        if str(input("swap? ")) == "":
            #_swapper()          
            pathnswap(paths)
def expllore():
    name_to_address = openfileasjson("book.txt")
    pooldata = openfileasjson("pooldata.txt")
    token_to_pools = openfileasjson("token_to_pools.txt")

    while True:
        what_to_do = ""
        while what_to_do == "":
            what_to_do = str(input("what to do? "))
            if what_to_do == "pooldata":
                print(pooldata[str(input("address: "))])
            elif what_to_do == "ttm":
                print(token_to_pools[name_to_address[str(input("token: "))]])
            elif what_to_do == "paths":
                path_cli(name_to_address, pooldata, token_to_pools)
                what_to_do = ""
                

def find_all_pools_of_tokens():
    pooldata = openfileasjson("pooldata.txt")
    name_to_address = openfileasjson("book.txt")
    token_to_pools = openfileasjson("token_to_pools.txt")
    
    while True:
        start_token = ""
        while start_token == "":
            try:
                start_token = name_to_address[str(input("start token: "))]
            except KeyError: 
                pass

        end_token = ""
        while end_token == "":
            try:
                end_token = name_to_address[str(input("end token: "))]
            except KeyError:
                pass
        for pool, data in pooldata.items():
            token0 = data['token0']['id']
            token1 = data['token1']['id']
            tokens = [token0, token1]
            if start_token in tokens and end_token in tokens:
                
                assert pool in token_to_pools[start_token]
                assert pool in token_to_pools[end_token]
                print(pool)
                print(token0)
                print(token1)
                print(data['pool_type'])
                print("")
                
            
def path_to_router_path(path):
    p = []
    for params in path:
        pp = []
        for param in params:
            for v in param.values():
                pp += [v]
        p += [tuple(pp)]
    return p

def main():
    #expllore()
    #find_all_pools_of_tokens()
    path_cli()
    
    
    #priority_fee("2 gwei")
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
    #uni3pools = getAllUni3Pools()
    #save_paths()
    
    #save_uni3_data()
    # uni3pools = openfileasjson("uni3_data.txt")
    # sushipools = openfileasjson("sushipools.txt")
    # uni2pools = openfileasjson("univ2pools.txt")
    # pools = [uni3pools, sushipools, uni2pools]

    #saveasjson("book.txt", symbol_to_address(uni3pools))
    
    #print(len(pools[0]) + len(pools[1]) + len(pools[2]))
    #add_pool_params(sushipools, "sushipools.txt", 0)
    #add_pool_params(uni2pools, "univ2pools.txt", 0)
    #add_pool_params(uni3pools, "uni3_data.txt", 1)
    #print(make_lower(sushipools))
    #dta("sushipools.txt", sushipools)
    #dta("univ2pools.txt", uni2pools)
    
    #saveasjson("univ2pools.txt", make_lower(uni2pools))
    #saveasjson("sushipools.txt", make_lower(sushipools))
    #print(uni3pools)
    #pooldata = pool_to_params(pools)
    #print(len(pooldata))

    #pooldata = openfileasjson("pooldata.txt")
    #token_to_pools = openfileasjson("token_to_pools.txt")

    # # # # for p in uni3pools:
    # # # #     print(p)
    #print(sushipools)
    # start = time.time()
    # token_to_pool_dic = token_to_markets(pools)
    # end = time.time()
    # print(end - start)
    # print("bing")
    # saveasjson("pooldata.txt", pooldata)
    # print("bong")
    # saveasjson("token_to_pools.txt", token_to_markets(pools))
    # print("bang")
    #print("dong")

    # pool_to_data_dic = pool_to_params(pools)
    # #paths = find_paths(token_to_pool_dic, pool_to_data_dic)
    # #profit = swaploop(paths, pool_to_data_dic, (10**18))
    #paths = path_search(token_to_pools, pooldata)
    #saveasjson("paths_test.txt", paths)


    #_cli()
    
