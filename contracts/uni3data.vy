# @version 0.3.3

struct Slot0:
       sqrtPriceX96: uint160
       tick: int24
       observationIndex: uint16
       observationCardinality: uint16
       observationCardinalityNext: uint16
       feeProtocol: uint8
       unlocked: bool

struct Tick:
        liquidityGross: uint128 
        liquidityNet: uint128 
        feeGrowthOutside0X128: uint256 
        feeGrowthOutside1X128: uint256 
        tickCumulativeOutside: int56 
        secondsPerLiqudityOutsideX128: uint160 
        secondsOutside: uint32 
        initialized: bool


interface IUniswapV3PoolState:
          def slot0() -> Slot0: view
          def liquidity() -> uint128: view
          def ticks(tick: int24) -> Tick: view
          def tickSpacing() -> int24: view


@view
@internal
def _slot0(pool_state: IUniswapV3PoolState) -> Slot0:
    return pool_state.slot0()

@view
@internal
def _tick(pool_state: IUniswapV3PoolState, tick_: int24,) -> Tick:
    return pool_state.ticks(tick_)

@view
@external
def get_slot0(pool_addr: address) -> Slot0:
    return self._slot0(IUniswapV3PoolState(pool_addr))

@view
@external
def get_tick(pool_addr: address, tick: int24) -> Tick:
    return self._tick(IUniswapV3PoolState(pool_addr), tick)

ONE: constant(int24) = 1

@view
@external
def get_ticks(pool_addr: address) -> DynArray[int24, 20]:
    pool: IUniswapV3PoolState = IUniswapV3PoolState(pool_addr)
    spacing: int24 = pool.tickSpacing()
    s0: Slot0 = pool.slot0()
    currentTick: int24 = s0.tick
    ticks: DynArray[int24, 20] = empty(DynArray[int24, 20])
    cT128: int128 = convert(currentTick, int128)
    s128: int128 = convert(spacing, int128)
    for i in range(1,10):
        r: int128 = cT128 - s128 * i
        ticks[i] = convert(r, int24)
    for i in range(0,10):
        r: int128 = cT128 + s128 * i
        ticks[i + 10] = convert(r, int24)
    return ticks

@view
@external
def tick_spacing(addr: address) -> int24:
    return IUniswapV3PoolState(addr).tickSpacing()
    
# struct PoolData:
#        slot0: Slot0
#        ticks: DynArray[Tick, 100]

# struct calldata:
#        addr: address
#        ticks: DynArray[int24, 100]

# @view
# @internal
# def _tick_info(_ticks: DynArray[int24, 100], pool_addr: address) -> DynArray[Tick, 100]:
#     r: DynArray[Tick, 100] = empty(DynArray[Tick, 100])
#     pool: IUniswapV3PoolState = IUniswapV3PoolState(pool_addr)
#     length: uint256 = len(_ticks)
#     for i in range(100):
#         if (i >= 100 or i >= length):
#            break
#         tick_info: Tick = pool.ticks(_ticks[i]) 
#         r[i] = tick_info
#     return r

# @view
# @external
# def pool_info(uni3_pool: DynArray[calldata, 1000]) -> DynArray[PoolData,1000]:
#     data: DynArray[PoolData, 1000] = empty(DynArray[PoolData, 1000])
#     length: uint256 = len(uni3_pool)   
#     for i in range(1000):
#         if (i >= 1000 or i >= length):
#            break
#         pool: IUniswapV3PoolState = IUniswapV3PoolState(uni3_pool[i].addr)
#         pool_slot0: Slot0 = pool.slot0()
#         _ticks: DynArray[Tick, 100] = self._tick_info(uni3_pool[i].ticks, uni3_pool[i].addr)
#         pd:PoolData = PoolData({slot0: pool_slot0, ticks: _ticks})
#         data[i] = pd
#     return data
        

