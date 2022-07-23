import brownie
from brownie import curveData, accounts, Contract
import json

PRECISION = 10**18
A_PRECISION = 100
FEE_DENOMINATOR = 10**10

def get_pools():
    registry = Contract("0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5")
    count = registry.pool_count()
    for i in range(count):
        print(registry.pool_list(i))


def get_pool_info(agg):
    registry = Contract("0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5")
    count = registry.pool_count()
    pool_infos = {}
    for i in range(count):
        try:
            print(i)
            addr = registry.pool_list(i)
            pool_infos[addr] = agg.pool_info(registry.address, addr).dict()
        except:
            pass
    
    return pool_infos

def save_info(agg):
    info = get_pool_info(agg)
    f = open("curve_data.txt", "w")
    f.write(json.dumps(info))
    f.close()

def load_info():
    f = open("curve_data.txt")
    info = json.load(f)
    f.close()
    return info

def N_COINS(curve_pool):
    if curve_pool['meta']:
        return curve_pool['Ncoins'][1]
    else:
        return curve_pool['Ncoins'][0]


def _xp(curve_pool):
    result = []
    for rate in curve_pool['rates']:
        if rate != 0:
            result += [rate] 
    n_coins = N_COINS(curve_pool)
    for i in range(n_coins):
        bal = curve_pool['balances'][i]
        result[i] =  result[i] * bal / PRECISION
#    print(result)
    return result
    

def index_of_token(curve_pool, token):
    for index, coin in enumerate(curve_pool['coins']):
        print(coin)
        if coin == token:
            return index
        
def get_D(xp, amp, curve_pool):
    S = int(0)
    Dprev = int(0)
    n_coins = int(N_COINS(curve_pool))
    for _x in xp:
        S += _x
    if S == 0:
        return 0
    D = S
    ann = int(amp * n_coins)
    for _i in range(255):
        D_P = D
        #print(D)
        #print(Dprev)
        #print(_i)
        for _x in xp:
            # print("D_P", D_P)
            # print("D", D)
            # print("_x", _x)
            # print("n_coins", n_coins)
            D_P = D_P * D // (_x * n_coins)
        Dprev = D
        D = (ann * S // A_PRECISION + D_P * n_coins) * D // ((ann - A_PRECISION) * D // A_PRECISION + (n_coins + 1) * D_P)
        if D > Dprev:
            if D - Dprev <= 1:
                break
            
        else:
            if Dprev - D <= 1:
                break
    return D
                

def get_y(i, j, x, xp_, curve_pool):
    n_coins = N_COINS(curve_pool)
    A_ = curve_pool['params'][0]
    D = get_D(xp_, A_, curve_pool)
    Ann = A_ * n_coins
    c = D
    S_ = 0
    _x = 0
    y_prev = 0

    for _i in range(n_coins):
        if _i == i:
            _x = x
        elif _i != j:
            _x = xp_[_i]
        else:
            pass
        S_ += -x
        c = c * D / (_x * n_coins)
    c = c * D * A_PRECISION / (Ann * n_coins)
    b = S_ + D * A_PRECISION / Ann
    y = D
    for _i in range(255):
        y_prev = y
        y = (y*y + c) / (2*y+b-D)
        if y > y_prev:
            if y - y_prev <= 1:
                break
        else:
            if y_prev - y <= 1:
                break
    return y
    
    

def get_dy(curve_pool, tokenIn, tokenOut, amountIn):
    i = index_of_token(curve_pool, tokenIn)
    j = index_of_token(curve_pool, tokenOut)
    dx = amountIn
    fee = curve_pool['params'][2]
    rates = curve_pool['rates']
    xp = _xp(curve_pool)

    x = xp[i] + (dx * rates[i] / PRECISION)
    y = get_y(i, j, x, xp, curve_pool)
    dy = (xp[j] - y) * PRECISION / rates[j]
    _fee = fee * dy / FEE_DENOMINATOR
    result = (dy - _fee)
    return result

def test_get_dy():
    c = curveData.deploy({"from": accounts[0]})
    #c = curveData[-1]
    registry = Contract("0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5")
    pool_addr = registry.pool_list(0)
    curve_pool = c.pool_info(registry.address, pool_addr)
    for k in curve_pool:
        print(k)
    tokenIn = curve_pool['coins'][0]
    tokenOut = curve_pool['coins'][1]
#    print(tokenIn)
#    print(tokenOut)
    amountIn = 10**18
    my_dy = get_dy(curve_pool, tokenIn, tokenOut, amountIn)
    i = 1
    j = 2
    dx = 10**18
    real_dy = c.test_dy(i,j,dx,pool_addr)
    print("c", my_dy)
    print("r", real_dy)
    percent_error = ((my_dy - real_dy) / real_dy) * 100
    print(f"percent error {percent_error}%")
    
def main():
    # provider = Contract("0x0000000022D53366457F9d5E68Ec105046FC4383")
    # registry = Contract("0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5")
    # pool_count = registry.pool_count()
    # poolInfo = Contract("0xe64608E223433E8a03a1DaaeFD8Cb638C14B552C")
    # pools = {}
    # for i in range(pool_count):
    #     addr = registry.pool_list(i)
    #     coins = poolInfo.get_pool_coins(addr).dict()
    #     info = poolInfo.get_pool_info(addr).dict()
    #     info['coins'] = coins['coins']
    #     info['underlying_coins'] = coins['underlying_coins']
    #     pools[addr] = info
    #     print(i)
    # print(pools)

    #registry = "0x90E00ACe148ca3b23Ac1bC8C240C2a7Dd9c2d7f5"

    test_get_dy()
    # c = curveData.deploy({"from": accounts[0]})
    # save_info(c)
    # curve_pools = load_info()
    # for pool, params in curve_pools.items():

    #     print("pool", pool)
    #     for param, value in params.items():
    #         print(param, value)

            
    #infos = get_pool_info(c)
    #print(infos)
    #get_pool_info(c)
    #info = c.infoo(registry)
    #    c = curveData[-1]
    #info = c.get_info(registry)
    #print(info)
        

        
