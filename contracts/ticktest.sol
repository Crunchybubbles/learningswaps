pragma solidity >=0.5.0 <0.8.0;
pragma abicoder v2;

import "Uniswap/v3-core@1.0.0/contracts/libraries/TickMath.sol";
import "Uniswap/v3-core@1.0.0/contracts/libraries/SwapMath.sol";
import "Uniswap/v3-core@1.0.0/contracts/libraries/SqrtPriceMath.sol";
//import "Uniswap/uniswap-v3-periphery@1.3.0/contracts/libraries/Path.sol";
//import "Uniswap/uniswap-v3-periphery@1.3.0/contracts/interfaces/ISwapRouter.sol";
//import "Openzeppelin/openzeppelin-contracts@3.0.0/contracts/token/ERC20/IERC20.sol";


interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Pool {
    struct Slot0 {
        // the current price
        uint160 sqrtPriceX96;
        // the current tick
        int24 tick;
        // the most-recently updated index of the observations array
        uint16 observationIndex;
        // the current maximum number of observations that are being stored
        uint16 observationCardinality;
        // the next maximum number of observations to store, triggered in observations.write
        uint16 observationCardinalityNext;
        // the current protocol fee as a percentage of the swap fee taken on withdrawal
        // represented as an integer denominator (1/x)%
        uint8 feeProtocol;
        // whether the pool is locked
        bool unlocked;
    }
	function slot0() external view returns (Slot0 memory s0);
	function swap(address recipient,
		      bool zeroForOne,
		      int256 amountSpecified,
		      uint160 sqrtPriceLimitX96,
		      bytes calldata data
		      ) external returns (int256 amount0, int256 amount1);
	function liquidity() external view returns (uint128);
	function ticks(int24 tick) external view returns (
							  uint128 liquidityGross,
							  int128 liquidityNet,
							  uint256 feeGrowthOutside0X128,
							  uint256 feeGrowthOutside1X128,
							  int56 tickCumulativeOutside,
							  uint160 secondsPerLiquidityOutsideX128,
							  uint32 secondsOutside,
							  bool initialized
							  );
}


interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

contract TickTest {
    uint160 internal constant MIN_SQRT_RATIO = 4295128740;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970341;



    struct SwapParams {
	address pool;
	address tokenIn;
	address tokenOut;
    }

    function swapExactIn(address pool, address tokenIn, address tokenOut, int256 amountIn, bool zeroForOne) public returns (int256 amount0, int256 amount1) {
	uint160 priceLimit = zeroForOne ? MIN_SQRT_RATIO:MAX_SQRT_RATIO;
	SwapParams memory params = SwapParams({pool: pool, tokenIn: tokenIn, tokenOut: tokenOut});
	bytes memory _data = abi.encode(params);
	IUniswapV3Pool(pool).swap(address(this), zeroForOne, amountIn, priceLimit, _data);
    }

    function uniswapV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes calldata _data) external {
	SwapParams memory params = abi.decode(_data, (SwapParams));
	address tokenIn = params.tokenIn;
	address tokenOut = params.tokenOut;

	(bool isExactInput, uint256 amountToPay) =
            _amount0Delta > 0
                ? (tokenIn < tokenOut, uint256(_amount0Delta))
                : (tokenOut < tokenIn, uint256(_amount1Delta));
	if (isExactInput) {
	    IERC20(tokenIn).transfer(msg.sender, amountToPay);
	} else {
	    IERC20(tokenOut).transfer(msg.sender, amountToPay);
	}
		
    }

    function get_s0(address pool) public view returns (IUniswapV3Pool.Slot0 memory) {
	return IUniswapV3Pool(pool).slot0();
    }

    function get_liquidity(address pool) public view returns (uint128) {
	return IUniswapV3Pool(pool).liquidity();
    }

    function check_ticks(int24[] _tickIdxs) public view returns (bool) {
    }

    function approveToken(address token, address to_be_approved) public {
	IERC20(token).approve(to_be_approved, type(uint256).max);
    }


    
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

    


    /* //    using Path for bytes;
    /* struct SwapCallbackData { */
    /* 	/\* bytes path; *\/ */
    /* 	/\* address payer; *\/ */
    /* 	address pool; */
    /* } */

    /* function pay(address _token, address _pool, uint256 _value) internal { */
    /* 	ERC20(_token).transferFrom(self, _pool, _value); */
    /* } */

	

    /* function uniswapV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes calldata _data) external { */
    /* 	SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData)); */
    /*     (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool(); */
    /*     //CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee); */

    /*     (bool isExactInput, uint256 amountToPay) = */
    /*         amount0Delta > 0 */
    /*             ? (tokenIn < tokenOut, uint256(amount0Delta)) */
    /*             : (tokenOut < tokenIn, uint256(amount1Delta)); */
    /*     if (isExactInput) { */
    /*         pay(tokenIn, data.payer, msg.sender, amountToPay); */
    /*     } else { */
    /*         // either initiate the next swap or pay */
    /*         /\* if (data.path.hasMultiplePools()) { *\/ */
    /*         /\*     data.path = data.path.skipToken(); *\/ */
    /*         /\*     exactOutputInternal(amountToPay, msg.sender, 0, data); *\/ */
    /*         /\* } else { *\/ */
    /*         /\*     //amountInCached = amountToPay; *\/ */
    /*         /\*     tokenIn = tokenOut; // swap in/out because exact output swaps are reversed *\/ */
    /*         /\*     pay(tokenIn, data.payer, msg.sender, amountToPay); *\/ */
    /* 	    pay(tokenIn, data.payer, msg.sender, amountToPay); */
	    
    /* 	    //} */
    /* 	} */
	
    /* } */


}
