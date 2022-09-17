# @version 0.3.4



interface IERC20:
    def transferFrom(_from: address, _to: address, amount: uint256) -> bool: nonpayable
    def transfer(_to: address, _amount: uint256) -> bool: nonpayable
    def balanceOf(account: address) -> uint256: view

interface IUni3Pool:
    def swap(recipient: address, zeroForOne: bool, amountSpecified: int256, sqrtPriceLimitX96: uint160, data: Bytes[64]) -> (int256, int256): nonpayable
    #(amount0, amount1)

interface IUni2Pool:
    def swap(amount0Out: uint256, amount1Out: uint256, to: address, data: Bytes[32]): nonpayable
    def getReserves() -> (uint112, uint112, uint32): view

owner: address

struct Params:
    pool_type: uint256
    pool: address
    token0: address
    token1: address
    amountIn: uint256
    amountOut: uint256
    zeroForOne: bool
    amountSpecified: int256
    sqrtPriceLimitX96: uint160


struct callBackParams:
    token0: address
    token1: address

MAX_PATH_LENGTH: constant(uint256) = 20
CALL_BACK_LENGTH: constant(uint256) = 64

@external
def __init__():
    self.owner = msg.sender


@internal
def step_along_path(step_params: Params):
    if (step_params.pool_type == 0):
       #univ2pool
       pool: IUni2Pool = IUni2Pool(step_params.pool)
       data: Bytes[32] = empty(Bytes[32])
       if (step_params.zeroForOne):
          assert IERC20(step_params.token0).transfer(step_params.pool, step_params.amountIn)
          pool.swap(0, step_params.amountOut, self, data)
       else:
          assert IERC20(step_params.token1).transfer(step_params.pool, step_params.amountIn)
          pool.swap(step_params.amountOut, 0, self, data)
    elif (step_params.pool_type == 1):
       #univ3pool
       pool: IUni3Pool = IUni3Pool(step_params.pool)
       token0: address = step_params.token0
       token1: address = step_params.token1
       _callBackParams: callBackParams = callBackParams({token0: token0, token1: token1})
       _data: Bytes[CALL_BACK_LENGTH] = _abi_encode(_callBackParams)
       pool.swap(self, step_params.zeroForOne, step_params.amountSpecified, step_params.sqrtPriceLimitX96, _data)

@internal
def calc_univ2_amountOut(_pool: address, tokenIn: address, zeroForOne: bool, amountIn: uint256) -> (uint256):
    pool: IUni2Pool = IUni2Pool(_pool)
    
    reserve0: uint112 = 0
    reserve1: uint112 = 0
    blockTimestamplast: uint32 = 0
    reserve0, reserve1, blockTimestamplast = pool.getReserves()

    reserveOut: uint256 = 0
    reserveIn: uint256 = 0
    if (zeroForOne):
       reserveOut = convert(reserve0, uint256)
       reserveIn = convert(reserve1, uint256)
    else:
       reserveOut = convert(reserve1, uint256)
       reserveIn = convert(reserve0, uint256)
    amountInWithFee: uint256 = amountIn * 977
    return (amountInWithFee * reserveOut) / ((reserveIn * 1000) + amountInWithFee)
    
    
    


@external
def swap_along_path(path: DynArray[Params, MAX_PATH_LENGTH], start_token: address, end_token: address, to: address):
    if (path[0].pool_type == 0):
        assert IERC20(start_token).transferFrom(msg.sender, self, path[0].amountIn)
    elif (path[0].pool_type == 1):
        assert IERC20(start_token).transferFrom(msg.sender, self, convert(path[0].amountSpecified, uint256))
        
    for i in range(MAX_PATH_LENGTH):
        if (i >= len(path)):
           break
        if (path[i].amountIn == 0 and path[i].amountSpecified == 0):
           if (path[i].pool_type == 0):
              if (path[i].zeroForOne):
                 path[i].amountIn = IERC20(path[i].token0).balanceOf(self)
                 path[i].amountOut = self.calc_univ2_amountOut(path[i].pool, path[i].token0, True, path[i].amountIn)
              else:
                 path[i].amountIn = IERC20(path[i].token1).balanceOf(self)
                 path[i].amountOut = self.calc_univ2_amountOut(path[i].pool, path[i].token1, False, path[i].amountIn)
           elif (path[i].pool_type == 1):
              if (path[i].zeroForOne):
                 path[i].amountSpecified = convert(IERC20(path[i].token0).balanceOf(self), int256)
              else:
                 path[i].amountSpecified = convert(IERC20(path[i].token1).balanceOf(self), int256)
        self.step_along_path(path[i])
    bal: uint256 = IERC20(end_token).balanceOf(self)
    IERC20(end_token).transfer(to, bal)
    

@external
def uniswapV3SwapCallback(amount0delta: int256, amount1delta: int256, _data: Bytes[CALL_BACK_LENGTH]):
    data: callBackParams = _abi_decode(_data, (callBackParams))
    if (amount0delta > 0):
       assert IERC20(data.token0).transfer(msg.sender, convert(amount0delta, uint256))
    elif (amount1delta > 0):
       assert IERC20(data.token1).transfer(msg.sender, convert(amount1delta, uint256))
