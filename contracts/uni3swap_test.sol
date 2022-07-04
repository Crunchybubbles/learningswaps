pragma solidity =0.7.6;
pragma abicoder v2;

/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/SafeCast.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/LowGasSafeMath.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/FullMath.sol'; */
/* //import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/Oracle.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/Tick.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/FixedPoint128.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/SwapMath.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/TickBitmap.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/libraries/TickMath.sol'; */
/* //import 'Uniswap/uniswap-v3-core@1.0.0/contracts/interfaces/IUniswapV3Pool.sol'; */
/* import 'Uniswap/uniswap-v3-core@1.0.0/contracts/NoDelegateCall.sol'; */

/* interface IUniswapV3Pool { */

/*     struct Slot0 { */
/*         // the current price */
/*         uint160 sqrtPriceX96; */
/*         // the current tick */
/*         int24 tick; */
/*         // the most-recently updated index of the observations array */
/*         uint16 observationIndex; */
/*         // the current maximum number of observations that are being stored */
/*         uint16 observationCardinality; */
/*         // the next maximum number of observations to store, triggered in observations.write */
/*         uint16 observationCardinalityNext; */
/*         // the current protocol fee as a percentage of the swap fee taken on withdrawal */
/*         // represented as an integer denominator (1/x)% */
/*         uint8 feeProtocol; */
/*         // whether the pool is locked */
/* 	bool unlocked; */
/*     } */
/*     function slot0() external view returns (Slot0 memory); */
/*     function liquidity() external view returns (uint128); */
/*     function feeGrowthGlobal0X128() external view returns (uint256); */
/*     function feeGrowthGlobal1X128() external view returns (uint256); */
/*     function fee() external view returns (uint24); */
/*     //function ticks(int24 _tick) external view returns (Info memory); */
/*     function tickSpacing() external view returns (int24); */
/*     //function tickBitmap() external view returns (mapping(int16 => uint256) memory); */
    
/* } */

/* contract swapTest is NoDelegateCall { */
/*     using LowGasSafeMath for uint256; */
/*     using LowGasSafeMath for int256; */
/*     using SafeCast for uint256; */
/*     using SafeCast for int256; */
/*     using Tick for mapping(int24 => Tick.Info); */
/*     using TickBitmap for mapping(int16 => uint256); */
/*     mapping(int16 => uint256) public tickBitmap; */
/*     mapping(int24 => Tick.Info) public ticks; */
/*     function _blockTimestamp() internal view virtual returns (uint32) { */
/*         return uint32(block.timestamp); // truncation is desired */
/*     } */
/*     struct SwapCache { */
/*         // the protocol fee for the input token */
/*         uint8 feeProtocol; */
/*         // liquidity at the beginning of the swap */
/*         uint128 liquidityStart; */
/*         // the timestamp of the current block */
/*         uint32 blockTimestamp; */
/*         // the current value of the tick accumulator, computed only if we cross an initialized tick */
/*         int56 tickCumulative; */
/*         // the current value of seconds per liquidity accumulator, computed only if we cross an initialized tick */
/*         uint160 secondsPerLiquidityCumulativeX128; */
/*         // whether we've computed and cached the above two accumulators */
/*         bool computedLatestObservation; */
/*     } */

/*     // the top level state of the swap, the results of which are recorded in storage at the end */
/*     struct SwapState { */
/*         // the amount remaining to be swapped in/out of the input/output asset */
/*         int256 amountSpecifiedRemaining; */
/*         // the amount already swapped out/in of the output/input asset */
/*         int256 amountCalculated; */
/*         // current sqrt(price) */
/*         uint160 sqrtPriceX96; */
/*         // the tick associated with the current price */
/*         int24 tick; */
/*         // the global fee growth of the input token */
/*         uint256 feeGrowthGlobalX128; */
/*         // amount of input token paid as protocol fee */
/*         uint128 protocolFee; */
/*         // the current liquidity in range */
/*         uint128 liquidity; */
/*     } */

/*     struct StepComputations { */
/*         // the price at the beginning of the step */
/*         uint160 sqrtPriceStartX96; */
/*         // the next tick to swap to from the current tick in the swap direction */
/*         int24 tickNext; */
/*         // whether tickNext is initialized or not */
/*         bool initialized; */
/*         // sqrt(price) for the next tick (1/0) */
/*         uint160 sqrtPriceNextX96; */
/*         // how much is being swapped in in this step */
/*         uint256 amountIn; */
/*         // how much is being swapped out */
/*         uint256 amountOut; */
/*         // how much fee is being paid in */
/*         uint256 feeAmount; */
/*     } */


/* 	function swap( */
/* 		  address pool_addr, */
/* 		  //address recipient, */
/* 		  bool zeroForOne, */
/* 		  int256 amountSpecified, */
/* 		  uint160 sqrtPriceLimitX96 */
/* 		  //bytes calldata data */
/* 		  ) public view noDelegateCall returns (int256 amount0, int256 amount1) { */
/*         require(amountSpecified != 0, 'AS'); */
/* 	IUniswapV3Pool pool = IUniswapV3Pool(pool_addr); */
/*         IUniswapV3Pool.Slot0 memory slot0Start = pool.slot0(); */
	
/*         require(slot0Start.unlocked, 'LOK'); */
/*         require( */
/*             zeroForOne */
/*                 ? sqrtPriceLimitX96 < slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 > TickMath.MIN_SQRT_RATIO */
/*                 : sqrtPriceLimitX96 > slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 < TickMath.MAX_SQRT_RATIO, */
/*             'SPL' */
/*         ); */

/* 	//   slot0.unlocked = false; */

/*         SwapCache memory cache = */
/*             SwapCache({ */
/*                 liquidityStart: pool.liquidity(), */
/*                 blockTimestamp: _blockTimestamp(), */
/*                 feeProtocol: zeroForOne ? (slot0Start.feeProtocol % 16) : (slot0Start.feeProtocol >> 4), */
/*                 secondsPerLiquidityCumulativeX128: 0, */
/*                 tickCumulative: 0, */
/*                 computedLatestObservation: false */
/*             }); */

/*         bool exactInput = amountSpecified > 0; */

/*         SwapState memory state = */
/*             SwapState({ */
/*                 amountSpecifiedRemaining: amountSpecified, */
/*                 amountCalculated: 0, */
/*                 sqrtPriceX96: slot0Start.sqrtPriceX96, */
/*                 tick: slot0Start.tick, */
/*                 feeGrowthGlobalX128: zeroForOne ? pool.feeGrowthGlobal0X128() : pool.feeGrowthGlobal1X128(), */
/*                 protocolFee: 0, */
/*                 liquidity: cache.liquidityStart */
/*             }); */

/*         // continue swapping as long as we haven't used the entire input/output and haven't reached the price limit */
/*         while (state.amountSpecifiedRemaining != 0 && state.sqrtPriceX96 != sqrtPriceLimitX96) { */
/*             StepComputations memory step; */

/*             step.sqrtPriceStartX96 = state.sqrtPriceX96; */

/*             (step.tickNext, step.initialized) = tickBitmap.nextInitializedTickWithinOneWord(											     */
/* 											    state.tick, */
/* 											    pool.tickSpacing(), */
/* 											    zeroForOne */
/* 											    ); */

/*             // ensure that we do not overshoot the min/max tick, as the tick bitmap is not aware of these bounds */
/*             if (step.tickNext < TickMath.MIN_TICK) { */
/*                 step.tickNext = TickMath.MIN_TICK; */
/*             } else if (step.tickNext > TickMath.MAX_TICK) { */
/*                 step.tickNext = TickMath.MAX_TICK; */
/*             } */

/*             // get the price for the next tick */
/*             step.sqrtPriceNextX96 = TickMath.getSqrtRatioAtTick(step.tickNext); */

/*             // compute values to swap to the target tick, price limit, or point where input/output amount is exhausted */
/*             (state.sqrtPriceX96, step.amountIn, step.amountOut, step.feeAmount) = SwapMath.computeSwapStep( */
/*                 state.sqrtPriceX96, */
/*                 (zeroForOne ? step.sqrtPriceNextX96 < sqrtPriceLimitX96 : step.sqrtPriceNextX96 > sqrtPriceLimitX96) */
/*                     ? sqrtPriceLimitX96 */
/*                     : step.sqrtPriceNextX96, */
/*                 state.liquidity, */
/*                 state.amountSpecifiedRemaining, */
/*                 pool.fee() */
/*             ); */

/*             if (exactInput) { */
/*                 state.amountSpecifiedRemaining -= (step.amountIn + step.feeAmount).toInt256(); */
/*                 state.amountCalculated = state.amountCalculated.sub(step.amountOut.toInt256()); */
/*             } else { */
/*                 state.amountSpecifiedRemaining += step.amountOut.toInt256(); */
/*                 state.amountCalculated = state.amountCalculated.add((step.amountIn + step.feeAmount).toInt256()); */
/*             } */

/*             // if the protocol fee is on, calculate how much is owed, decrement feeAmount, and increment protocolFee */
/*             if (cache.feeProtocol > 0) { */
/*                 uint256 delta = step.feeAmount / cache.feeProtocol; */
/*                 step.feeAmount -= delta; */
/*                 state.protocolFee += uint128(delta); */
/*             } */

/*             // update global fee tracker */
/*             if (state.liquidity > 0) */
/*                 state.feeGrowthGlobalX128 += FullMath.mulDiv(step.feeAmount, FixedPoint128.Q128, state.liquidity); */

/*             // shift tick if we reached the next price */
/*             if (state.sqrtPriceX96 == step.sqrtPriceNextX96) { */
/*                 // if the tick is initialized, run the tick transition */
/*                 if (step.initialized) { */
/*                     // check for the placeholder value, which we replace with the actual value the first time the swap */
/*                     // crosses an initialized tick */
/*                     /\* if (!cache.computedLatestObservation) { *\/ */
/*                     /\*     (cache.tickCumulative, cache.secondsPerLiquidityCumulativeX128) = observations.observeSingle( *\/ */
/*                     /\*         cache.blockTimestamp, *\/ */
/*                     /\*         0, *\/ */
/*                     /\*         slot0Start.tick, *\/ */
/*                     /\*         slot0Start.observationIndex, *\/ */
/*                     /\*         cache.liquidityStart, *\/ */
/*                     /\*         slot0Start.observationCardinality *\/ */
/*                     /\*     ); *\/ */
/*                     /\*     cache.computedLatestObservation = true; *\/ */
/*                     /\* } *\/ */
/*                     int128 liquidityNet = */
/*                         ticks.cross( */
/*                             step.tickNext, */
/*                             (zeroForOne ? state.feeGrowthGlobalX128 : pool.feeGrowthGlobal0X128()), */
/*                             (zeroForOne ? pool.feeGrowthGlobal1X128() : state.feeGrowthGlobalX128), */
/*                             cache.secondsPerLiquidityCumulativeX128, */
/*                             cache.tickCumulative, */
/*                             cache.blockTimestamp */
/*                         ); */
/*                     // if we're moving leftward, we interpret liquidityNet as the opposite sign */
/*                     // safe because liquidityNet cannot be type(int128).min */
/*                     if (zeroForOne) liquidityNet = -liquidityNet; */

/*                     state.liquidity = LiquidityMath.addDelta(state.liquidity, liquidityNet); */
/*                 } */

/*                 state.tick = zeroForOne ? step.tickNext - 1 : step.tickNext; */
/*             } else if (state.sqrtPriceX96 != step.sqrtPriceStartX96) { */
/*                 // recompute unless we're on a lower tick boundary (i.e. already transitioned ticks), and haven't moved */
/*                 state.tick = TickMath.getTickAtSqrtRatio(state.sqrtPriceX96); */
/*             } */
/*         } */

/*         (amount0, amount1) = zeroForOne == exactInput */
/*             ? (amountSpecified - state.amountSpecifiedRemaining, state.amountCalculated) */
/*             : (state.amountCalculated, amountSpecified - state.amountSpecifiedRemaining); */
/*     } */
/* } */
