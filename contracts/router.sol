pragma solidity 0.7.6;
pragma abicoder v2;

interface IERC20 {
    function transferFrom(address _from, address _to, uint256 amount) external returns (bool);
    function approve(address toBeApproved, uint256 howMuch) external;
}

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

interface IAaveFlashLoanProvider {
    function flashloan(
		       address receiverAddress,
		       address[] calldata assets,
		       uint256[] calldata amounts,
		       uint256[] calldata modes,
		       address onBehalfOf,
		       bytes calldata params,
		       uint16 referralCode
		       ) external;
}


contract Router {

    IAaveFlashLoanProvider aaveFlash;
    address owner;

    modifier onlyOwner {
	if (msg.sender != owner) {
	    revert();
	}
        _;
    }
    
    constructor(address _aaveFlash) {
	aaveFlash = IAaveFlashLoanProvider(_aaveFlash);
	owner = msg.sender;
    }

    struct Params {
	uint256 pool_type;
	address pool;
	address token0;
	address token1;
	//	uint256 reserves0;
	//	uint256 reserves1;
	uint256 amountIn;
	uint256 amountOut;
	bool zeroForOne;
	int256 amountSpecified;
	uint160 sqrtPriceLimitX96;
    }

    struct UniswapV3CallbackParams {
	address token0;
	address token1;
	address payer;
    }

    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata _data) external {
	UniswapV3CallbackParams memory data = abi.decode(_data, (UniswapV3CallbackParams));

	if (amount0 > 0) {
	    require(IERC20(data.token0).transferFrom(data.payer, msg.sender, uint256(amount0)));
	} else if (amount1 > 0) {
	    require(IERC20(data.token1).transferFrom(data.payer, msg.sender, uint256(amount1)));
	}
	
	
    }


    function _swapAlongPath(Params[] memory params) internal {
	uint256 pathLength = params.length;
	for (uint256 i; i < pathLength; i++) {

	    if (params[i].pool_type == 0) {

		IUni2Pool pool = IUni2Pool(params[i].pool);
		if (params[i].zeroForOne) {
		    IERC20(params[i].token0).transferFrom(msg.sender, params[i].pool, params[i].amountIn); 
		    pool.swap(0, params[i].amountOut, msg.sender, "");
		} else {
		    IERC20(params[i].token1).transferFrom(msg.sender, params[i].pool, params[i].amountIn);
		    pool.swap(params[i].amountOut, 0, msg.sender, "");
		}
		
	    } else if (params[i].pool_type == 1) {

		IUni3Pool pool = IUni3Pool(params[i].pool);
		UniswapV3CallbackParams memory _callBackParams;
		_callBackParams.token0 = params[i].token0;
		_callBackParams.token1 = params[i].token1;
		_callBackParams.payer = msg.sender;
		bytes memory _data = abi.encode(_callBackParams);
		pool.swap(msg.sender, params[i].zeroForOne, params[i].amountSpecified, params[i].sqrtPriceLimitX96, _data);

	    } else if (params[i].pool_type == 2) {

		ICurvePool pool = ICurvePool(params[i].pool);
	    }
	}
    }

    function swapAlongPath(Params[] calldata _params) external {
	_swapAlongPath(_params);
    }

    function executeOperation(address[] calldata assets,
			      address[] calldata amounts,
			      uint256[] calldata premiums,
			      address initiator,
			      bytes calldata params
			      ) external returns (bool) {

	
	_swapAlongPath(abi.decode(params, (Params[])));
	
	return true;
    }
			      
    function flashAndSwapDownPath(address[] calldata assets, uint256[] calldata amounts, Params[] calldata params) public {
	uint256[] memory modes = new uint256[](assets.length);
    
	aaveFlash.flashloan(address(this), assets, amounts, modes, address(this), abi.encode(params), 0);
	

    }

    function approveTokenSpender(address toBeApproved, address token) public onlyOwner {
	IERC20(token).approve(toBeApproved, type(uint256).max);
    }
	 
      
   


}
