import brownie
from brownie import accounts, Router, Contract, interface, vyper_router

YFI_ETH_V2_POOL = "0x2fdbadf3c4d5a8666bc06645b8358ab803996e28"

YFI_ETH_V3_POOL = "0x04916039B1f59D9745Bf6E0a21f191D1e0A84287"
DAI_ETH_V3_POOL = "0x60594a405d53811d3BC4766596EFD80fd545A270"
YFI = "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e"
DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F"
WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"

MIN_SQRT_PRICE = 4295128740
MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970341

DAI_WHALE = "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643"
WETH_WHALE = "0xf04a5cc80b1e94c69b48f5ee68a08cd2f09a7c3e"


aave_flash = "0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9"

def get_token_from_whale(Token_addr, whale_addr, amount, recipient):
    token = Contract(Token_addr)
    print(f"{recipient} balance for {Token_addr} | {token.balanceOf(recipient)}")
    token.transfer(recipient, amount, {"from": whale_addr})
    print(f"{recipient} balance for {Token_addr} | {token.balanceOf(recipient)}")

def test_v3_two_hops():
    r = Router.deploy(aave_flash, {"from": accounts[0]})
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
    r = Router.deploy(aave_flash, {"from": accounts[0]})
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

def test_v3_single_hop_vyper():
    r = vyper_router.deploy({"from": accounts[0]})
    get_token_from_whale(DAI, DAI_WHALE, Contract(DAI).balanceOf(DAI_WHALE), accounts[0])
    
    pool_type = 1
    pool = DAI_ETH_V3_POOL
    token0 = DAI
    token1 = WETH
    amountIn = 0
    amountOut = 0
    zeroForOne = True
    amountSpecified = Contract(DAI).balanceOf(accounts[0]) * 10**-6
    sqrtPriceLimit = MIN_SQRT_PRICE
    print(amountSpecified * 10**-18)

    params1= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)
    params = [params1]
    
    Contract(DAI).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    r.swap_along_path(params, DAI, WETH, accounts[0], {"from": accounts[0]})


def test_test_v3_single_hop_vyper():
    r = vyper_router[-1]
    
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
    params = [params1]
    
    
    r.swap_along_path(params, DAI, WETH, accounts[0], {"from": accounts[0]})

    
def test_v3_two_hops_vyper():
    r = vyper_router.deploy({"from": accounts[0]})
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
    print(amountSpecified * 10**-18)


    params1= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)


    pool_type = 1
    pool = YFI_ETH_V3_POOL
    token0 = YFI
    token1 = WETH
    amountIn = 0
    amountOut = 0
    zeroForOne = False
    amountSpecified = 0
    sqrtPriceLimit = MAX_SQRT_PRICE

    
    params2= (pool_type, pool, token0, token1, amountIn, amountOut, zeroForOne, amountSpecified, sqrtPriceLimit)
    
    params = [params1, params2]


    #Contract(WETH).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    Contract(DAI).approve(r.address, (2**256) - 1, {"from": accounts[0]})
    r.swap_along_path(params, DAI, YFI, accounts[0], {"from": accounts[0]})

def test_v2_v3_vyper():
    r = vyper_router.deploy({"from": accounts[0]})
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
    r.swap_along_path(params,  accounts[0], {"from": accounts[0]})
def df():
    vyper_router.deploy({"from": accounts[0]})
    get_token_from_whale(YFI, YFI_WHALE, Contract(YFI).balanceOf(YFI_WHALE), accounts[0])
    Contract(YFI).approve(vyper_router[-1], (2**256)-1, {"from": accounts[0]})    
    
def main():
    #test_v3_two_hops() #it worked! #gas used 4611265
    #test_v2_v3()
    #test_v3_two_hops_vyper() #first attempt failed used gas used 4487309
    #test_v3_single_hop_vyper()
    df()
    #test_test_v3_single_hop_vyper()
    #print(Contract(DAI).balanceOf(accounts[0]))
    #print(Contract(YFI).balanceOf(accounts[0]))
