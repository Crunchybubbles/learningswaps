pragma solidity 0.7.6;
pragma abicoder v2;

interface IUni3Pool {
    function swap(address recipient,
		  bool zeroForOne,
		  int256 amountSpecified,
		  uint160 sqrtPriceLimitX96,
		  bytes calldata data
		  ) external returns (int256 amount0, int256 amount1);

}

interface IUni2Pool {
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function token0() external view returns (uint256);
    function token1() external view returns (uint256);
}

interface ICurvePool {
    /* function exchange(address _pool, */
    /* 		      address _from, */
    /* 		      address _to, */
    /* 		      uint256 _amount, */
    /* 		      uint256 _expected, */
    /* 		      address _receiver */
    /* 		      ) external payable returns (uint256); */
    function exchange(int128 i, int128 j, uint256 dx, uint256 dy) external;
    
}


contract Router {

    struct Params {
	uint256 pool_type;
	address pool;
	address token0;
	address token1;
	uint256 reserves0;
	uint256 reserves1;
	uint256 amountOut;
	bool zeroForOne;
	int256 amountSpecified;
	uint160 sqrtPriceLimitX96;

    }

	

    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata data) external {
	
    }


    function swapAlongPath(Params[] calldata params) public {
	uint256 pathLength = params.length;
	for (uint256 i; i < pathLength; i++) {
	    if (params[i].pool_type == 0) {
		IUni2Pool pool = IUni2Pool(params[i].pool);
		if (params[i].zeroForOne) {
		    pool.swap(0, params[i].amountOut, address(this), "");
		} else {
		    pool.swap(params[i].amountOut, 0, address(this), "");
		}
		
	    } else if (params[i].pool_type == 1) {
		IUni3Pool pool = IUni3Pool(params[i].pool);
		pool.swap(address(this), params[i].zeroForOne, params[i].amountSpecified, params[i].sqrtPriceLimitX96, "");
	    } else if (params[i].pool_type == 2) {
		ICurvePool pool = ICurvePool(params[i].pool);
	    }
	}
    }
	    
	
	 
      
   


}
