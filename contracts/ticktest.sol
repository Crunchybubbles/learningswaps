/* pragma solidity >=0.5.0 <0.8.0; */
/* pragma abicoder v2; */

/* import "uniswapV3_core/contracts/libraries/TickMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/BitMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/TickBitmap.sol"; */
/* import "uniswapV3_core/contracts/libraries/SwapMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/FullMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/SqrtPriceMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/LiquidityMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/LowGasSafeMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/SafeCast.sol"; */
/* //import "Uniswap/uniswap-v3-periphery@1.3.0/contracts/libraries/Path.sol"; */
/* //import "Uniswap/uniswap-v3-periphery@1.3.0/contracts/interfaces/ISwapRouter.sol"; */
/* //import "Openzeppelin/openzeppelin-contracts@3.0.0/contracts/token/ERC20/IERC20.sol"; */


/* interface IERC20 { */
/*     function transfer(address recipient, uint256 amount) external returns (bool); */
/*     function approve(address spender, uint256 amount) external returns (bool); */
/*     function balanceOf(address account) external view returns (uint256); */
/* } */


/* interface IUniswapV3Pool { */
/*     event Swap( */
/*         address indexed sender, */
/*         address indexed recipient, */
/*         int256 amount0, */
/*         int256 amount1, */
/*         uint160 sqrtPriceX96, */
/*         uint128 liquidity, */
/*         int24 tick */
/*     ); */
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
/*         bool unlocked; */
/*     } */


/*     /\* struct Tick { *\/ */
/*     /\* 	uint128 liquidityGross; *\/ */
/*     /\* 	int128 liquidityNet; *\/ */
/*     /\* 	uint256 feeGrowthOutside0X128; *\/ */
/*     /\* 	uint256 feeGrowthOutside1X128; *\/ */
/*     /\* 	int56 tickCumulativeOutside; *\/ */
/*     /\* 	uint160 secondsPerLiquidityOutsideX128; *\/ */
/*     /\* 	uint32 secondsOutside; *\/ */
/*     /\* 	bool initialized; *\/ */
/*     /\* } *\/ */


/*     function slot0() external view returns (Slot0 memory s0); */
/*     function swap(address recipient, */
/* 		  bool zeroForOne, */
/* 		  int256 amountSpecified, */
/* 		  uint160 sqrtPriceLimitX96, */
/* 		  bytes calldata data */
/* 		  ) external returns (int256 amount0, int256 amount1); */
/*     function liquidity() external view returns (uint128); */
/*     function ticks(int24 tick) external view returns ( */
/* 						      uint128 liquidityGross, */
/* 						      int128 liquidityNet, */
/* 						      uint256 feeGrowthOutside0X128, */
/* 						      uint256 feeGrowthOutside1X128, */
/* 						      int56 tickCumulativeOutside, */
/* 						      uint160 secondsPerLiquidityOutsideX128, */
/* 						      uint32 secondsOutside, */
/* 						      bool initialized */
/* 						      ); */
/*     function tickBitmap(int16 wordPosition) external view returns (uint256); */
/*     function tickSpacing() external view returns (int24); */
/*     function fee() external view returns (uint24); */
/*     function token0() external view returns (address); */
/*     function token1() external view returns (address); */
/* } */


/* interface IUni2Pool { */
/*     function getReserves() external view returns (uint112, uint112, uint32); */
    
/* } */

/* interface ISwapRouter { */
/*     struct ExactInputSingleParams { */
/*         address tokenIn; */
/*         address tokenOut; */
/*         uint24 fee; */
/*         address recipient; */
/*         uint256 deadline; */
/*         uint256 amountIn; */
/*         uint256 amountOutMinimum; */
/*         uint160 sqrtPriceLimitX96; */
/*     } */
/*     function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut); */
/* } */

/* contract TickTest { */
/*     uint160 internal constant MIN_SQRT_RATIO = 4295128740; */
/*     uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970341; */



/*     struct SwapParams { */
/* 	address pool; */
/* 	address tokenIn; */
/* 	address tokenOut; */
/*     } */

/*     function swapExactIn(address pool, address tokenIn, address tokenOut, int256 amountIn, bool zeroForOne) public returns (int256 amount0, int256 amount1) { */
/* 	uint160 priceLimit = zeroForOne ? MIN_SQRT_RATIO:MAX_SQRT_RATIO; */
/* 	SwapParams memory params = SwapParams({pool: pool, tokenIn: tokenIn, tokenOut: tokenOut}); */
/* 	bytes memory _data = abi.encode(params); */
/* 	IUniswapV3Pool(pool).swap(address(this), zeroForOne, amountIn, priceLimit, _data); */
/*     } */

/*     function uniswapV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes calldata _data) external { */
/* 	SwapParams memory params = abi.decode(_data, (SwapParams)); */
/* 	address tokenIn = params.tokenIn; */
/* 	address tokenOut = params.tokenOut; */

/* 	(bool isExactInput, uint256 amountToPay) = */
/*             _amount0Delta > 0 */
/*                 ? (tokenIn < tokenOut, uint256(_amount0Delta)) */
/*                 : (tokenOut < tokenIn, uint256(_amount1Delta)); */
/* 	if (isExactInput) { */
/* 	    IERC20(tokenIn).transfer(msg.sender, amountToPay); */
/* 	} else { */
/* 	    IERC20(tokenOut).transfer(msg.sender, amountToPay); */
/* 	} */
		
/*     } */

/*     function get_s0(address pool) public view returns (IUniswapV3Pool.Slot0 memory) { */
/* 	return IUniswapV3Pool(pool).slot0(); */
/*     } */

/*     function get_liquidity(address pool) public view returns (uint128) { */
/* 	return IUniswapV3Pool(pool).liquidity(); */
/*     } */

/*     struct Tick { */
/* 	int128 liquidityNet; */
/* 	bool initialized; */
/*     } */

/*     function check_ticks(address _pool, int24 _tickIdx) public view returns ( */
/* 										 uint128, */
/* 										 int128, */
/* 										 uint256, */
/* 										 uint256, */
/* 										 int56, */
/* 										 uint160, */
/* 										 uint32, */
/* 										 bool) { */
/* 	return IUniswapV3Pool(_pool).ticks(_tickIdx); */
/*     } */

/*     /\* function nextTick(address _pool, int24 _currentTick, int24 _tick_spacing, bool zeroForOne) public view returns (int24, bool) { *\/ */
	
/*     /\* 	return TickBitmap.nextInitializedTickWithinOneWord(IUniswapV3Pool(_pool).tickBitmap(), _currentTick, _tick_spacing, zeroForOne);  *\/ */
/*     /\* } *\/ */

/*     function approveToken(address token, address to_be_approved) public { */
/* 	IERC20(token).approve(to_be_approved, type(uint256).max); */
/*     } */


    
/*     function priceFromTick(int24 tick) public pure returns(uint160 sqrtPriceX96) { */
/* 	return TickMath.getSqrtRatioAtTick(tick); */

/*     } */

/*     function swapStep( */
/* 		      uint160 current, */
/* 		      uint160 target, */
/* 		      uint128 liquidity, */
/* 		      int256 amountRemaing, */
/* 		      uint24 feePips */
/* 		      ) public pure returns (uint160 nextPrice, */
/* 					     uint256 amountIn, */
/* 					     uint256 amountOut, */
/* 					     uint256 feeAmount) { */
/* 	return SwapMath.computeSwapStep(current, */
/* 				 target, */
/* 				 liquidity, */
/* 				 amountRemaing, */
/* 				 feePips */
/* 				 ); */
/*     } */


/*     function amount0Delta(uint160 A, uint160 B, int128 liq) public pure returns (int256 amount0) { */
/* 	return SqrtPriceMath.getAmount0Delta(A, B, liq); */
/*     } */
    
/*     function amount1Delta(uint160 A, uint160 B, int128 liq) public pure returns (int256 amount1) { */
/* 	return SqrtPriceMath.getAmount1Delta(A, B, liq); */
/*     } */

/*     function sqrtPriceFromInput(uint160 p, uint128 l, uint256 a, bool z) public pure returns (uint160 nextP) { */
/* 	return SqrtPriceMath.getNextSqrtPriceFromInput(p, l, a, z); */
/*     } */

/*     function sqrtPriceFromOutput(uint160 p, uint128 l, uint256 a, bool z) public pure returns (uint160 nextP) { */
/* 	return SqrtPriceMath.getNextSqrtPriceFromOutput(p, l, a, z); */
/*     } */

/*     function tickFromPrice(uint160 price) public pure returns (int24) { */
/* 	return TickMath.getTickAtSqrtRatio(price); */
/*     } */

/*     function position(int24 tick) private pure returns (int16 wordPos, uint8 bitPos) { */
/*         wordPos = int16(tick >> 8); */
/*         bitPos = uint8(tick % 256); */
/*     } */

/*     function nextInitializedTickWithinOneWord( */
/* 					      address _pool, */
/* 					      int24 tick, */
/* 					      bool lte */
/* 					      ) public view returns (int24 next, bool initialized) { */
/* 	IUniswapV3Pool pool = IUniswapV3Pool(_pool); */
/* 	int24 tickSpacing = pool.tickSpacing(); */
/*         int24 compressed = tick / tickSpacing; */
/*         if (tick < 0 && tick % tickSpacing != 0) compressed--; // round towards negative infinity */

/*         if (lte) { */
/*             (int16 wordPos, uint8 bitPos) = position(compressed); */
/*             // all the 1s at or to the right of the current bitPos */
/*             uint256 mask = (1 << bitPos) - 1 + (1 << bitPos); */
/*             uint256 masked = pool.tickBitmap(wordPos) & mask; */

/*             // if there are no initialized ticks to the right of or at the current tick, return rightmost in the word */
/*             initialized = masked != 0; */
/*             // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick */
/*             next = initialized */
/*                 ? (compressed - int24(bitPos - BitMath.mostSignificantBit(masked))) * tickSpacing */
/*                 : (compressed - int24(bitPos)) * tickSpacing; */
/*         } else { */
/*             // start from the word of the next tick, since the current tick state doesn't matter */
/*             (int16 wordPos, uint8 bitPos) = position(compressed + 1); */
/*             // all the 1s at or to the left of the bitPos */
/*             uint256 mask = ~((1 << bitPos) - 1); */
/*             uint256 masked = pool.tickBitmap(wordPos) & mask; */

/*             // if there are no initialized ticks to the left of the current tick, return leftmost in the word */
/*             initialized = masked != 0; */
/*             // overflow/underflow is possible, but prevented externally by limiting both tickSpacing and tick */
/*             next = initialized */
/*                 ? (compressed + 1 + int24(BitMath.leastSignificantBit(masked) - bitPos)) * tickSpacing */
/*                 : (compressed + 1 + int24(type(uint8).max - bitPos)) * tickSpacing; */
/*         } */
/*     } */

/*     function mulDiv(uint256 n1, uint256 n2, uint256 d) public pure returns (uint256) { */
/* 	return FullMath.mulDiv(n1,n2,d); */
/*     } */

/*     function _liqNet(IUniswapV3Pool pool, int24 _tickNext) internal view returns (int128) { */
/* 	uint128 liquidityGross; */
/* 	int128 liquidityNet; */
/* 	uint256 feeGrowthOutside0X128; */
/* 	uint256 feeGrowthOutside1X128; */
/* 	int56 tickCumulativeOutside; */
/* 	uint160 secondsPerLiquidityOutsideX128; */
/* 	uint32 secondsOutside; */
/* 	bool initialized; */
		    
		    
/* 	(liquidityGross, liquidityNet, feeGrowthOutside0X128, feeGrowthOutside1X128, tickCumulativeOutside, secondsPerLiquidityOutsideX128, secondsOutside, initialized) =  pool.ticks(_tickNext); */
/* 	return liquidityNet; */
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
/*     using LowGasSafeMath for uint256; */
/*     using LowGasSafeMath for int256; */
/*     using SafeCast for uint256; */
/*     using SafeCast for int256; */

/*     uint160 constant MAX_SP = 1461446703485210103287273052203988822378723970341; */
/*     uint160 constant MIN_SP = 4295128740; */


/*     function ez_v3_calc(address _pool, uint256 amount, bool zeroForOne) public view returns(int256, int256) { */
/* 	uint160 lim = 0; */
/* 	if (zeroForOne) { */
/* 	    lim = MIN_SP; */
/* 	} else { */
/* 	    lim = MAX_SP; */
/* 	} */
/* 	int256 amount0; */
/* 	int256 amount1; */
/* 	(amount0, amount1) = calc_v3_swap(_pool, zeroForOne, int256(amount), lim); */
/* 	return (amount0, amount1); */
	
/*     } */

  
/*     function calc_v3_swap( */
/* 		  address _pool, */
/* 		  bool zeroForOne, */
/* 		  int256 amountSpecified, */
/* 		  uint160 sqrtPriceLimitX96 */
/* 		  ) public view returns (int256 amount0, int256 amount1) { */
/*         require(amountSpecified != 0, 'AS'); */

/* 	IUniswapV3Pool pool = IUniswapV3Pool(_pool); */
/* 	uint24 fee = pool.fee(); */
	
/*         IUniswapV3Pool.Slot0 memory slot0Start = pool.slot0() ; */

/*         require(slot0Start.unlocked, 'LOK'); */
/*         require( */
/*             zeroForOne */
/*                 ? sqrtPriceLimitX96 < slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 > TickMath.MIN_SQRT_RATIO */
/*                 : sqrtPriceLimitX96 > slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 < TickMath.MAX_SQRT_RATIO, */
/*             'SPL' */
/*         ); */

/*         bool exactInput = amountSpecified > 0; */

/*         SwapState memory state = */
/*             SwapState({ */
/*                 amountSpecifiedRemaining: amountSpecified, */
/*                 amountCalculated: 0, */
/*                 sqrtPriceX96: slot0Start.sqrtPriceX96, */
/*                 tick: slot0Start.tick, */
/*                 protocolFee: 0, */
/*                 liquidity: pool.liquidity() */
/*             }); */

/*         // continue swapping as long as we haven't used the entire input/output and haven't reached the price limit */
/*         while (state.amountSpecifiedRemaining != 0 && state.sqrtPriceX96 != sqrtPriceLimitX96) { */
/*             StepComputations memory step; */

/*             step.sqrtPriceStartX96 = state.sqrtPriceX96; */
/* 	    // replace this with function call  */
/*             (step.tickNext, step.initialized) = nextInitializedTickWithinOneWord( */
/* 										 _pool, */
/* 										 state.tick, */
/* 										 zeroForOne */
/*             ); */

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
/*                 fee */
/*             ); */

/*             if (exactInput) { */
/*                 state.amountSpecifiedRemaining -= int256(step.amountIn + step.feeAmount); */
/*                 state.amountCalculated = state.amountCalculated.sub(int256(step.amountOut)); */
/*             } else { */
/*                 state.amountSpecifiedRemaining += int256(step.amountOut); */
/*                 state.amountCalculated = state.amountCalculated.add(int256(step.amountIn + step.feeAmount)); */
/*             } */

/*             // shift tick if we reached the next price */
/*             if (state.sqrtPriceX96 == step.sqrtPriceNextX96) { */
/*                 // if the tick is initialized, run the tick transition */
/*                 if (step.initialized) { */

/* 		    int128 liquidityNet = _liqNet(pool, step.tickNext); */
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


/* 	if (zeroForOne) { */
/* 	    require(uint256(amount1 * -1) < IERC20(pool.token1()).balanceOf(address(this))); */
/* 	} else { */
/* 	    require(uint256(amount0 * -1) < IERC20(pool.token0()).balanceOf(address(this))); */
/* 	} */
	
/*     } */


/*     function calc_univ2_amountOut(address _pool, bool _zeroForOne, uint256 _amountIn) public view returns (uint256) { */
/* 	IUni2Pool pool = IUni2Pool(_pool); */
/* 	uint112 reserve0; */
/* 	uint112 reserve1; */

/* 	uint32 blockTimestamp; */
/* 	(reserve0, reserve1, blockTimestamp) = pool.getReserves(); */

/* 	uint256 preK = uint256(reserve0) * uint256(reserve1); */
	
/* 	uint256 reserveOut; */
/* 	uint256 reserveIn; */

/* 	uint256 amountOut; */
/* 	uint256 amountInWithFee; */


/* 	if (_zeroForOne) { */
/* 	    reserveOut = uint256(reserve0); */
/* 	    reserveIn = uint256(reserve1); */
/* 	    amountInWithFee = _amountIn * 977; */
/* 	    amountOut = (amountInWithFee * reserveOut) / ((reserveIn * 1000) + amountInWithFee); */

/* 	} else { */
/* 	    reserveOut = uint256(reserve1); */
/* 	    reserveIn = uint256(reserve0); */
/*   	    amountInWithFee = _amountIn * 977; */
/* 	    amountOut = (amountInWithFee * reserveOut) / ((reserveIn * 1000) + amountInWithFee); */
	    	    
/* 	} */

	
/* 	if ((reserveOut + amountInWithFee) < type(uint256).max) { */
/* 	    reserveOut = reserveOut + amountInWithFee; */
/* 	} else { */
/* 	    return 0; */
/* 	} */
	
/* 	if (reserveIn > amountOut) { */
/* 	    reserveIn = reserveIn - amountOut; */
/* 	} else { */
/* 	    return 0; */
/* 	} */
	
/* 	if ((reserveIn * reserveOut) <= preK) { */
/* 	    return 0; */
/* 	} */
		
/* 	if (amountOut < reserveOut) { */
/* 	    return 0; */
/* 	} else { */
/* 	    return amountOut; */
/* 	} */
/*     } */

/*     struct Params { */
/* 	uint256 pool_type; */
/* 	address pool; */
/* 	address token0; */
/* 	address token1; */
/* 	uint256 amountIn; */
/* 	uint256 amountOut; */
/* 	bool zeroForOne; */
/* 	int256 amountSpecified; */
/* 	uint160 sqrtPriceLimitX96; */
/*     } */

/*     uint160 MIN_SQRT_PRICE = 4295128740; */
/*     uint160 MAX_SQRT_PRICE = 1461446703485210103287273052203988822378723970341; */
    

/*     function check_path(Params[] calldata params) public view returns (Params[] memory) { */
/* 	uint256 steps = params.length; */
/* 	Params[] memory path_params = new Params[](steps); */
/* 	for (uint256 i = 0; i < steps; i++) { */
/* 	    Params memory step;     */

/* 	    step.pool = params[i].pool; */
/* 	    step.token0 = params[i].token0; */
/* 	    step.token1 = params[i].token1; */
/* 	    step.zeroForOne = params[i].zeroForOne; */

/* 	    if (params[i].pool_type == 0) { */
	
/* 		if (i != 0) { */
/* 		    step.amountIn = path_params[i-1].amountOut; */
/* 		} else { */
/* 		    step.amountIn = params[i].amountIn; */
/* 		} */
		
/* 		uint256 _aO = calc_univ2_amountOut(step.pool, step.zeroForOne, step.amountIn); */
/* 		if (_aO == 0) { */
/* 		    revert(); */
/* 		} else { */
/* 		    step.amountOut = _aO; */
/* 		} */
		

		
/* 	    } else if (params[i].pool_type == 1) { */
/* 		step.pool_type = 1; */
/* 		if (i != 0) { */
/* 		    uint256 _prev = i - 1; */
/* 		    uint256 _prevAmountOut = path_params[_prev].amountOut; */
/* 		    step.amountSpecified = _prevAmountOut.toInt256(); */
/* 		} else { */
/* 		    step.amountSpecified = params[i].amountSpecified; */
/* 		} */
/* 		if (step.zeroForOne) { */
/* 		    step.sqrtPriceLimitX96 = MIN_SQRT_PRICE; */
/* 		} else { */
/* 		    step.sqrtPriceLimitX96 = MAX_SQRT_PRICE; */
/* 		} */
/* 		int256 a0; */
/* 		int256 a1; */
/* 		(a0, a1) = calc_v3_swap(step.pool, step.zeroForOne, step.amountSpecified, step.sqrtPriceLimitX96); */
/* 		if (a0 < 0) { */
/* 		    a0 = a0 * -1; */
/* 		    step.amountOut = uint256(a0); */
		    
/* 		} else if (a1 < 0) { */
/* 		    a1 = a1 * -1; */
/* 		    step.amountOut = uint256(a1); */
/* 		} */
		
/* 	    } */
/* 	    if (step.amountOut == 0) { */
/* 		revert(); */
/* 	    } */
/* 	    path_params[i] = step; */
/* 	} */
    
/* 	return path_params; */
/*     } */


/*     /\* //    using Path for bytes; */
/*     /\* struct SwapCallbackData { *\/ */
/*     /\* 	/\\* bytes path; *\\/ *\/ */
/*     /\* 	/\\* address payer; *\\/ *\/ */
/*     /\* 	address pool; *\/ */
/*     /\* } *\/ */

/*     /\* function pay(address _token, address _pool, uint256 _value) internal { *\/ */
/*     /\* 	ERC20(_token).transferFrom(self, _pool, _value); *\/ */
/*     /\* } *\/ */

	

/*     /\* function uniswapV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes calldata _data) external { *\/ */
/*     /\* 	SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData)); *\/ */
/*     /\*     (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool(); *\/ */
/*     /\*     //CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee); *\/ */

/*     /\*     (bool isExactInput, uint256 amountToPay) = *\/ */
/*     /\*         amount0Delta > 0 *\/ */
/*     /\*             ? (tokenIn < tokenOut, uint256(amount0Delta)) *\/ */
/*     /\*             : (tokenOut < tokenIn, uint256(amount1Delta)); *\/ */
/*     /\*     if (isExactInput) { *\/ */
/*     /\*         pay(tokenIn, data.payer, msg.sender, amountToPay); *\/ */
/*     /\*     } else { *\/ */
/*     /\*         // either initiate the next swap or pay *\/ */
/*     /\*         /\\* if (data.path.hasMultiplePools()) { *\\/ *\/ */
/*     /\*         /\\*     data.path = data.path.skipToken(); *\\/ *\/ */
/*     /\*         /\\*     exactOutputInternal(amountToPay, msg.sender, 0, data); *\\/ *\/ */
/*     /\*         /\\* } else { *\\/ *\/ */
/*     /\*         /\\*     //amountInCached = amountToPay; *\\/ *\/ */
/*     /\*         /\\*     tokenIn = tokenOut; // swap in/out because exact output swaps are reversed *\\/ *\/ */
/*     /\*         /\\*     pay(tokenIn, data.payer, msg.sender, amountToPay); *\\/ *\/ */
/*     /\* 	    pay(tokenIn, data.payer, msg.sender, amountToPay); *\/ */
	    
/*     /\* 	    //} *\/ */
/*     /\* 	} *\/ */
	
/*     /\* } *\/ */


/* } */
