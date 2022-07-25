pragma solidity =0.7.6;
pragma abicoder v2;
import 'uniswapV3_core/contracts/libraries/TickBitmap.sol';
import 'uniswapV3_core/contracts/libraries/TickMath.sol';
//import 'Uniswap/uniswap-v3-core@1.0.0/contracts/interfaces/pool/IUniswapV3Pool.sol';


interface IUniswapV3Pool {
    struct Slot0 {
	uint160 sqrtPriceX96;
        int24 tick;
	uint16 observationIndex;
	uint16 observationCardinality;
	uint16 observationCardinalityNext;
	uint8 feeProtocol;
	bool unlocked;
    }

    struct Tick {
	uint128 liquidityGross;
	int128 liquidityNet;
	uint256 feeGrowthOutside0X128;
	uint256 feeGrowthOutside1X128;
	int56 tickCumulativeOutside;
	uint160 secondsPerLiquidityOutsideX128;
	uint32 secondsOutside;
	bool initialized;
    }

    
    function slot0() external view returns (Slot0 memory);
    
    function ticks(int24 tick) external view returns (Tick memory);

    function tickSpacing() external view returns (int24);

    function liquidity() external view returns (uint128);
}


contract Uni3ticks {
    function getSqrtFromTick(int24 tick) public pure returns (uint160 sqrtPriceX96) {
	sqrtPriceX96 = TickMath.getSqrtRatioAtTick(tick);
    }

    struct Ticks {
	int24 tick;
	uint160 price;
	int128 liquidityNet;
    }

    /* function getPrices(int24[] calldata ticks) public pure returns (Prices[] memory) { */
    /* 	uint256 len = ticks.length - 1; */
    /* 	Prices[] memory prices = new Prices[](len); */
    /* 	for (uint256 i = 0; i < len;) { */
    /* 	    prices[i] = Prices({tick: ticks[i], price: getSqrtFromTick(ticks[i])}); */
    /* 	    ++i; */
    /* 	} */
    /* 	return prices; */
    /* } */

    struct PoolData {
	address pool_addr;
	uint160 current_price;
	int24 current_tick;
	uint128 liquidity;
	Ticks[] ticks_info;
	
    }

    function getTickData(address pool_addr, int24[] calldata _ticks) public view returns (Ticks[] memory) {
	IUniswapV3Pool pool = IUniswapV3Pool(pool_addr);

	uint256 len = _ticks.length;
	Ticks[] memory t = new Ticks[](len);
	for (uint256 i; i <= len - 1;) {
	    IUniswapV3Pool.Tick memory tick = pool.ticks(_ticks[i]);
	    uint160 price = getSqrtFromTick(_ticks[i]);
	    t[i] = Ticks({tick: _ticks[i], price: price, liquidityNet: tick.liquidityNet});
	    ++i;
	}
	return t;
    }
	
    function forPools(address[] calldata pools, int24[][] calldata pools_ticks) public view returns (PoolData[] memory) {
	uint256 len = pools.length;
	PoolData[] memory result = new PoolData[](len);
	for (uint256 i = 0; i <= len - 1;) {
	    IUniswapV3Pool pool = IUniswapV3Pool(pools[i]);
	    IUniswapV3Pool.Slot0 memory s0 = pool.slot0();
	    Ticks[] memory ticks = new Ticks[](pools_ticks[i].length);
	    ticks = getTickData(pools[i], pools_ticks[i]); 
	    result[i] = PoolData({pool_addr: pools[i], current_price: s0.sqrtPriceX96, current_tick: s0.tick, liquidity: pool.liquidity(), ticks_info: ticks});
	    
	    ++i;
	}
	return result;
    }
}
