/* pragma solidity 0.7.6; */

/* import "uniswapV3_core/contracts/libraries/LowGasSafeMath.sol"; */
/* import "uniswapV3_core/contracts/libraries/SafeCast.sol"; */

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


/* contract UniV3Calc { */

/*     function mostSignificantBit(uint256 x) internal pure returns (uint8 r) { */
/*         require(x > 0); */

/*         if (x >= 0x100000000000000000000000000000000) { */
/*             x >>= 128; */
/*             r += 128; */
/*         } */
/*         if (x >= 0x10000000000000000) { */
/*             x >>= 64; */
/*             r += 64; */
/*         } */
/*         if (x >= 0x100000000) { */
/*             x >>= 32; */
/*             r += 32; */
/*         } */
/*         if (x >= 0x10000) { */
/*             x >>= 16; */
/*             r += 16; */
/*         } */
/*         if (x >= 0x100) { */
/*             x >>= 8; */
/*             r += 8; */
/*         } */
/*         if (x >= 0x10) { */
/*             x >>= 4; */
/*             r += 4; */
/*         } */
/*         if (x >= 0x4) { */
/*             x >>= 2; */
/*             r += 2; */
/*         } */
/*         if (x >= 0x2) r += 1; */
/*     } */

/*         function leastSignificantBit(uint256 x) internal pure returns (uint8 r) { */
/*         require(x > 0); */

/*         r = 255; */
/*         if (x & type(uint128).max > 0) { */
/*             r -= 128; */
/*         } else { */
/*             x >>= 128; */
/*         } */
/*         if (x & type(uint64).max > 0) { */
/*             r -= 64; */
/*         } else { */
/*             x >>= 64; */
/*         } */
/*         if (x & type(uint32).max > 0) { */
/*             r -= 32; */
/*         } else { */
/*             x >>= 32; */
/*         } */
/*         if (x & type(uint16).max > 0) { */
/*             r -= 16; */
/*         } else { */
/*             x >>= 16; */
/*         } */
/*         if (x & type(uint8).max > 0) { */
/*             r -= 8; */
/*         } else { */
/*             x >>= 8; */
/*         } */
/*         if (x & 0xf > 0) { */
/*             r -= 4; */
/*         } else { */
/*             x >>= 4; */
/*         } */
/*         if (x & 0x3 > 0) { */
/*             r -= 2; */
/*         } else { */
/*             x >>= 2; */
/*         } */
/*         if (x & 0x1 > 0) r -= 1; */
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
/*                 ? (compressed - int24(bitPos - mostSignificantBit(masked))) * tickSpacing */
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
/*                 ? (compressed + 1 + int24(leastSignificantBit(masked) - bitPos)) * tickSpacing */
/*                 : (compressed + 1 + int24(type(uint8).max - bitPos)) * tickSpacing; */
/*         } */
/*     } */
/*  /// @notice Calculates sqrt(1.0001^tick) * 2^96 */
/*     /// @dev Throws if |tick| > max tick */
/*     /// @param tick The input tick for the above formula */
/*     /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0) */
/*     /// at the given tick */
/*     function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) { */
/*         uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick)); */
/*         require(absTick <= uint256(MAX_TICK), 'T'); */

/*         uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000; */
/*         if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128; */
/*         if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128; */
/*         if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128; */
/*         if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128; */
/*         if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128; */
/*         if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128; */
/*         if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128; */
/*         if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128; */
/*         if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128; */
/*         if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128; */
/*         if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128; */
/*         if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128; */
/*         if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128; */
/*         if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128; */
/*         if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128; */
/*         if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128; */
/*         if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128; */
/*         if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128; */
/*         if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128; */

/*         if (tick > 0) ratio = type(uint256).max / ratio; */

/*         // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96. */
/*         // we then downcast because we know the result always fits within 160 bits due to our tick input constraint */
/*         // we round up in the division so getTickAtSqrtRatio of the output price is always consistent */
/*         sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1)); */
/*     } */

/*     /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio */
/*     /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may */
/*     /// ever return. */
/*     /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96 */
/*     /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio */
/*     function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) { */
/*         // second inequality must be < because the price can never reach the price at the max tick */
/*         require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, 'R'); */
/*         uint256 ratio = uint256(sqrtPriceX96) << 32; */

/*         uint256 r = ratio; */
/*         uint256 msb = 0; */

/*         assembly { */
/*             let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := shl(5, gt(r, 0xFFFFFFFF)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := shl(4, gt(r, 0xFFFF)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := shl(3, gt(r, 0xFF)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := shl(2, gt(r, 0xF)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := shl(1, gt(r, 0x3)) */
/*             msb := or(msb, f) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             let f := gt(r, 0x1) */
/*             msb := or(msb, f) */
/*         } */

/*         if (msb >= 128) r = ratio >> (msb - 127); */
/*         else r = ratio << (127 - msb); */

/*         int256 log_2 = (int256(msb) - 128) << 64; */

/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(63, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(62, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(61, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(60, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(59, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(58, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(57, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(56, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(55, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(54, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(53, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(52, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(51, f)) */
/*             r := shr(f, r) */
/*         } */
/*         assembly { */
/*             r := shr(127, mul(r, r)) */
/*             let f := shr(128, r) */
/*             log_2 := or(log_2, shl(50, f)) */
/*         } */

/*         int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number */

/*         int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128); */
/*         int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128); */

/*         tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow; */
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

/*     uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342; */
/*     uint160 constant MIN_SQRT_RATIO = 4295128739; */

/*     int24 internal constant MIN_TICK = -887272; */
/*     int24 internal constant MAX_TICK = -MIN_TICK; */
    


/*     /\* function ez_v3_calc(address _pool, uint256 amount, bool zeroForOne) public view returns(int256, int256) { *\/ */
/*     /\* 	uint160 lim = 0; *\/ */
/*     /\* 	if (zeroForOne) { *\/ */
/*     /\* 	    lim = MIN_SP; *\/ */
/*     /\* 	} else { *\/ */
/*     /\* 	    lim = MAX_SP; *\/ */
/*     /\* 	} *\/ */
/*     /\* 	int256 amount0; *\/ */
/*     /\* 	int256 amount1; *\/ */
/*     /\* 	(amount0, amount1) = calc_v3_swap(_pool, zeroForOne, int256(amount), lim); *\/ */
/*     /\* 	return (amount0, amount1); *\/ */
	
/*     /\* } *\/ */


/*         /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0 */
/*     /// @param a The multiplicand */
/*     /// @param b The multiplier */
/*     /// @param denominator The divisor */
/*     /// @return result The 256-bit result */
/*     /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv */
/*     function mulDiv( */
/*         uint256 a, */
/*         uint256 b, */
/*         uint256 denominator */
/*     ) internal pure returns (uint256 result) { */
/*         // 512-bit multiply [prod1 prod0] = a * b */
/*         // Compute the product mod 2**256 and mod 2**256 - 1 */
/*         // then use the Chinese Remainder Theorem to reconstruct */
/*         // the 512 bit result. The result is stored in two 256 */
/*         // variables such that product = prod1 * 2**256 + prod0 */
/*         uint256 prod0; // Least significant 256 bits of the product */
/*         uint256 prod1; // Most significant 256 bits of the product */
/*         assembly { */
/*             let mm := mulmod(a, b, not(0)) */
/*             prod0 := mul(a, b) */
/*             prod1 := sub(sub(mm, prod0), lt(mm, prod0)) */
/*         } */

/*         // Handle non-overflow cases, 256 by 256 division */
/*         if (prod1 == 0) { */
/*             require(denominator > 0); */
/*             assembly { */
/*                 result := div(prod0, denominator) */
/*             } */
/*             return result; */
/*         } */

/*         // Make sure the result is less than 2**256. */
/*         // Also prevents denominator == 0 */
/*         require(denominator > prod1); */

/*         /////////////////////////////////////////////// */
/*         // 512 by 256 division. */
/*         /////////////////////////////////////////////// */

/*         // Make division exact by subtracting the remainder from [prod1 prod0] */
/*         // Compute remainder using mulmod */
/*         uint256 remainder; */
/*         assembly { */
/*             remainder := mulmod(a, b, denominator) */
/*         } */
/*         // Subtract 256 bit number from 512 bit number */
/*         assembly { */
/*             prod1 := sub(prod1, gt(remainder, prod0)) */
/*             prod0 := sub(prod0, remainder) */
/*         } */

/*         // Factor powers of two out of denominator */
/*         // Compute largest power of two divisor of denominator. */
/*         // Always >= 1. */
/*         uint256 twos = -denominator & denominator; */
/*         // Divide denominator by power of two */
/*         assembly { */
/*             denominator := div(denominator, twos) */
/*         } */

/*         // Divide [prod1 prod0] by the factors of two */
/*         assembly { */
/*             prod0 := div(prod0, twos) */
/*         } */
/*         // Shift in bits from prod1 into prod0. For this we need */
/*         // to flip `twos` such that it is 2**256 / twos. */
/*         // If twos is zero, then it becomes one */
/*         assembly { */
/*             twos := add(div(sub(0, twos), twos), 1) */
/*         } */
/*         prod0 |= prod1 * twos; */

/*         // Invert denominator mod 2**256 */
/*         // Now that denominator is an odd number, it has an inverse */
/*         // modulo 2**256 such that denominator * inv = 1 mod 2**256. */
/*         // Compute the inverse by starting with a seed that is correct */
/*         // correct for four bits. That is, denominator * inv = 1 mod 2**4 */
/*         uint256 inv = (3 * denominator) ^ 2; */
/*         // Now use Newton-Raphson iteration to improve the precision. */
/*         // Thanks to Hensel's lifting lemma, this also works in modular */
/*         // arithmetic, doubling the correct bits in each step. */
/*         inv *= 2 - denominator * inv; // inverse mod 2**8 */
/*         inv *= 2 - denominator * inv; // inverse mod 2**16 */
/*         inv *= 2 - denominator * inv; // inverse mod 2**32 */
/*         inv *= 2 - denominator * inv; // inverse mod 2**64 */
/*         inv *= 2 - denominator * inv; // inverse mod 2**128 */
/*         inv *= 2 - denominator * inv; // inverse mod 2**256 */

/*         // Because the division is now exact we can divide by multiplying */
/*         // with the modular inverse of denominator. This will give us the */
/*         // correct result modulo 2**256. Since the precoditions guarantee */
/*         // that the outcome is less than 2**256, this is the final result. */
/*         // We don't need to compute the high bits of the result and prod1 */
/*         // is no longer required. */
/*         result = prod0 * inv; */
/*         return result; */
/*     } */

/*     /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0 */
/*     /// @param a The multiplicand */
/*     /// @param b The multiplier */
/*     /// @param denominator The divisor */
/*     /// @return result The 256-bit result */
/*     function mulDivRoundingUp( */
/*         uint256 a, */
/*         uint256 b, */
/*         uint256 denominator */
/*     ) internal pure returns (uint256 result) { */
/*         result = mulDiv(a, b, denominator); */
/*         if (mulmod(a, b, denominator) > 0) { */
/*             require(result < type(uint256).max); */
/*             result++; */
/*         } */
/*     } */






    
/*      /// @notice Computes the result of swapping some amount in, or amount out, given the parameters of the swap */
/*     /// @dev The fee, plus the amount in, will never exceed the amount remaining if the swap's `amountSpecified` is positive */
/*     /// @param sqrtRatioCurrentX96 The current sqrt price of the pool */
/*     /// @param sqrtRatioTargetX96 The price that cannot be exceeded, from which the direction of the swap is inferred */
/*     /// @param liquidity The usable liquidity */
/*     /// @param amountRemaining How much input or output amount is remaining to be swapped in/out */
/*     /// @param feePips The fee taken from the input amount, expressed in hundredths of a bip */
/*     /// @return sqrtRatioNextX96 The price after swapping the amount in/out, not to exceed the price target */
/*     /// @return amountIn The amount to be swapped in, of either token0 or token1, based on the direction of the swap */
/*     /// @return amountOut The amount to be received, of either token0 or token1, based on the direction of the swap */
/*     /// @return feeAmount The amount of input that will be taken as a fee */
/*     function computeSwapStep( */
/*         uint160 sqrtRatioCurrentX96, */
/*         uint160 sqrtRatioTargetX96, */
/*         uint128 liquidity, */
/*         int256 amountRemaining, */
/*         uint24 feePips */
/*     ) */
/*         internal */
/*         pure */
/*         returns ( */
/*             uint160 sqrtRatioNextX96, */
/*             uint256 amountIn, */
/*             uint256 amountOut, */
/*             uint256 feeAmount */
/*         ) */
/*     { */
/*         bool zeroForOne = sqrtRatioCurrentX96 >= sqrtRatioTargetX96; */
/*         bool exactIn = amountRemaining >= 0; */

/*         if (exactIn) { */
/*             uint256 amountRemainingLessFee = mulDiv(uint256(amountRemaining), 1e6 - feePips, 1e6); */
/*             amountIn = zeroForOne */
/*                 ? SqrtPriceMath.getAmount0Delta(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, true) */
/*                 : SqrtPriceMath.getAmount1Delta(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, true); */
/*             if (amountRemainingLessFee >= amountIn) sqrtRatioNextX96 = sqrtRatioTargetX96; */
/*             else */
/*                 sqrtRatioNextX96 = SqrtPriceMath.getNextSqrtPriceFromInput( */
/*                     sqrtRatioCurrentX96, */
/*                     liquidity, */
/*                     amountRemainingLessFee, */
/*                     zeroForOne */
/*                 ); */
/*         } else { */
/*             amountOut = zeroForOne */
/*                 ? SqrtPriceMath.getAmount1Delta(sqrtRatioTargetX96, sqrtRatioCurrentX96, liquidity, false) */
/*                 : SqrtPriceMath.getAmount0Delta(sqrtRatioCurrentX96, sqrtRatioTargetX96, liquidity, false); */
/*             if (uint256(-amountRemaining) >= amountOut) sqrtRatioNextX96 = sqrtRatioTargetX96; */
/*             else */
/*                 sqrtRatioNextX96 = SqrtPriceMath.getNextSqrtPriceFromOutput( */
/*                     sqrtRatioCurrentX96, */
/*                     liquidity, */
/*                     uint256(-amountRemaining), */
/*                     zeroForOne */
/*                 ); */
/*         } */

/*         bool max = sqrtRatioTargetX96 == sqrtRatioNextX96; */

/*         // get the input/output amounts */
/*         if (zeroForOne) { */
/*             amountIn = max && exactIn */
/*                 ? amountIn */
/*                 : SqrtPriceMath.getAmount0Delta(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, true); */
/*             amountOut = max && !exactIn */
/*                 ? amountOut */
/*                 : SqrtPriceMath.getAmount1Delta(sqrtRatioNextX96, sqrtRatioCurrentX96, liquidity, false); */
/*         } else { */
/*             amountIn = max && exactIn */
/*                 ? amountIn */
/*                 : SqrtPriceMath.getAmount1Delta(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, true); */
/*             amountOut = max && !exactIn */
/*                 ? amountOut */
/*                 : SqrtPriceMath.getAmount0Delta(sqrtRatioCurrentX96, sqrtRatioNextX96, liquidity, false); */
/*         } */

/*         // cap the output amount to not exceed the remaining output amount */
/*         if (!exactIn && amountOut > uint256(-amountRemaining)) { */
/*             amountOut = uint256(-amountRemaining); */
/*         } */

/*         if (exactIn && sqrtRatioNextX96 != sqrtRatioTargetX96) { */
/*             // we didn't reach the target, so take the remainder of the maximum input as fee */
/*             feeAmount = uint256(amountRemaining) - amountIn; */
/*         } else { */
/*             feeAmount = FullMath.mulDivRoundingUp(amountIn, feePips, 1e6 - feePips); */
/*         } */
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
/*                 ? sqrtPriceLimitX96 < slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 > MIN_SQRT_RATIO */
/*                 : sqrtPriceLimitX96 > slot0Start.sqrtPriceX96 && sqrtPriceLimitX96 < MAX_SQRT_RATIO, */
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
/*             if (step.tickNext < MIN_TICK) { */
/*                 step.tickNext = MIN_TICK; */
/*             } else if (step.tickNext > MAX_TICK) { */
/*                 step.tickNext = MAX_TICK; */
/*             } */

/*             // get the price for the next tick */
/*             step.sqrtPriceNextX96 = getSqrtRatioAtTick(step.tickNext); */

/*             // compute values to swap to the target tick, price limit, or point where input/output amount is exhausted */
/*             (state.sqrtPriceX96, step.amountIn, step.amountOut, step.feeAmount) = computeSwapStep( */
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
/*                 state.tick = getTickAtSqrtRatio(state.sqrtPriceX96); */
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



/* } */


