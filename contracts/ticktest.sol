pragma solidity >=0.5.0 <0.8.0;

import "Uniswap/v3-core@1.0.0/contracts/libraries/TickMath.sol";
import "Uniswap/v3-core@1.0.0/contracts/libraries/SwapMath.sol";
import "Uniswap/v3-core@1.0.0/contracts/libraries/SqrtPriceMath.sol";


contract TickTest {
    function priceFromTick(int24 tick) public pure returns(uint160 sqrtPriceX96) {
	return TickMath.getSqrtRatioAtTick(tick);

    }

    function swapStep(
		      uint160 current,
		      uint160 target,
		      uint128 liquidity,
		      int256 amountRemaing,
		      uint24 feePips
		      ) public pure returns (uint160 nextPrice,
					     uint256 amountIn,
					     uint256 amountOut,
					     uint256 feeAmount) {
	return SwapMath.computeSwapStep(current,
				 target,
				 liquidity,
				 amountRemaing,
				 feePips
				 );
    }


    function amount0Delta(uint160 A, uint160 B, int128 liq) public pure returns (int256 amount0) {
	return SqrtPriceMath.getAmount0Delta(A, B, liq);
    }
    
    function amount1Delta(uint160 A, uint160 B, int128 liq) public pure returns (int256 amount1) {
	return SqrtPriceMath.getAmount1Delta(A, B, liq);
    }

    function sqrtPriceFromInput(uint160 p, uint128 l, uint256 a, bool z) public pure returns (uint160 nextP) {
	return SqrtPriceMath.getNextSqrtPriceFromInput(p, l, a, z);
    }

    function sqrtPriceFromOutput(uint160 p, uint128 l, uint256 a, bool z) public pure returns (uint160 nextP) {
	return SqrtPriceMath.getNextSqrtPriceFromOutput(p, l, a, z);
    }


}
