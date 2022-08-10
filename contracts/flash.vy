# @version 0.3.4
"""
@title Base Aave V3 Flash Loan Simple Receiver
@license MIT
@author bsh98
@notice Vyper implementation of Aave V3 Flash Loan Simple
"""
# yfi buyback contract mev strat

# step 1: get yfi
# possible ways are
# - flashloan yfi
# - flashloan token, sell token for yfi. (token probably weth)

# step 2:
# sell yfi buy dai

# step 3: what to do with the dai?
# if flashloan:
#    sell dai for enough token/yfi to repay flashloan and the rest to eth
   
# step 4: bribe miners
#      give miner a cut of the eth


from vyper.interfaces import ERC20
YFI: constant(address) = 0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e
DAI: constant(address) = 0x6B175474E89094C44Da98b954EedeAC495271d0F
YFI_USD: constant(address) = 0xA027702dbb89fbd58938e4324ac03B58d812b0E1
WETH: constant(address) = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
STALE_AFTER: constant(uint256) = 3600
# set constants to desired level
MAX_PARAMS_LEN: constant(uint256) = 32
MAX_ASSETS_LEN: constant(uint256) = 32
MIN_SQRT_RATIO: constant(uint160) = 4295128740
MAX_SQRT_RATIO: constant(uint160) = 1461446703485210103287273052203988822378723970341
YFI_BUYER: constant(address) = 0x6903223578806940bd3ff0C51f87aa43968424c8
DAI_ETH_V3_POOL: constant(address) = 0x60594a405d53811d3BC4766596EFD80fd545A270
YFI_ETH_V3_POOL: constant(address) = 0x04916039B1f59D9745Bf6E0a21f191D1e0A84287

YFI_ETH_v2_POOL: constant(address) = 0x2fDbAdf3C4D5A8666Bc06645B8358ab803996E28


FLASH_POOL: constant(address) = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9

struct ChainlinkRound:
    roundId: uint80
    answer: int256
    startedAt: uint256
    updatedAt: uint256
    answeredInRound: uint80

interface Chainlink:
    def latestRoundData() -> ChainlinkRound: view

interface yfi_buyer:
    def buy_dai(yfi_amount: uint256): nonpayable
    def max_amount() -> uint256: view

interface univ3_pool:
    def swap(
        recipient: address,
        zeroForOne: bool,
        amountSpecified: int256,
        sqrtPriceLimitX96: uint160,
        data: Bytes[1024]
        ): nonpayable
        
interface univ2_pool:
    def swap(
        amount0Out: uint256,
        amount1Out: uint256,
        to: address,
        data: Bytes[1024]
        ): nonpayable
    def skim(to: address): nonpayable

interface univ3_quoter:
    def quoteExactInputSingle(
        tokenIn: address,
        tokenOut: address,
        fee: uint24,
        amountIn: uint256,
        sqrtPriceLimitX96: uint160
        ) -> uint256: nonpayable

    def quoteExactOutputSingle(
        tokenIn: address,
        tokenOut: address,
        fee: uint24,
        amountOut: uint256,
        sqrtPriceLimitX96: uint160
        ) -> uint256: nonpayable
        
    

event flashed:
      value: uint256

event test_params:
      value: Bytes[MAX_PARAMS_LEN]

event token_balances:
      token: address
      bal: uint256

@external
def __init__():
    ERC20(YFI).approve(FLASH_POOL, MAX_UINT256)
    ERC20(YFI).approve(YFI_BUYER, MAX_UINT256)      
    ERC20(DAI).approve(DAI_ETH_V3_POOL, MAX_UINT256)
    ERC20(WETH).approve(YFI_ETH_V3_POOL, MAX_UINT256)

@external
def executeOperation(
    _asset: DynArray[address, MAX_ASSETS_LEN],
    _amount: DynArray[uint256 , MAX_ASSETS_LEN],
    _premium: DynArray[uint256, MAX_ASSETS_LEN],
    _initiator: address,
    _params: Bytes[MAX_PARAMS_LEN]
) -> bool: 
    # conduct logic
    bal_berfore: uint256 = self.balance
    amount_owed: uint256 = _amount[0] + _premium[0]

    log token_balances(YFI, ERC20(YFI).balanceOf(self))
    log token_balances(DAI, ERC20(DAI).balanceOf(self))
    log token_balances(WETH, ERC20(WETH).balanceOf(self))

    yfi_buyer(YFI_BUYER).buy_dai(_amount[0])

    log token_balances(YFI, ERC20(YFI).balanceOf(self))
    log token_balances(DAI, ERC20(DAI).balanceOf(self))
    log token_balances(WETH, ERC20(WETH).balanceOf(self))
    
    univ3_pool(DAI_ETH_V3_POOL).swap(self, True, convert(ERC20(DAI).balanceOf(self), int256), MIN_SQRT_RATIO, b"")

    log token_balances(YFI, ERC20(YFI).balanceOf(self))
    log token_balances(DAI, ERC20(DAI).balanceOf(self))
    log token_balances(WETH, ERC20(WETH).balanceOf(self))
    
    univ3_pool(YFI_ETH_V3_POOL).swap(self, False, -convert(amount_owed, int256), MAX_SQRT_RATIO, b"")

    log token_balances(YFI, ERC20(YFI).balanceOf(self))
    log token_balances(DAI, ERC20(DAI).balanceOf(self))
    log token_balances(WETH, ERC20(WETH).balanceOf(self))
    
    ERC20(_asset[0]).approve(FLASH_POOL, amount_owed)      

    log token_balances(YFI, ERC20(YFI).balanceOf(self))
    log token_balances(DAI, ERC20(DAI).balanceOf(self))
    log token_balances(WETH, ERC20(WETH).balanceOf(self))
    bal_after: uint256 = self.balance
#    assert bal_after > bal_berfore
    return True

@internal
def _flash_call(
    _assets: DynArray[address, MAX_ASSETS_LEN],
    _amounts: DynArray[uint256, MAX_ASSETS_LEN],
    _interest_rate_modes: DynArray[uint256, MAX_ASSETS_LEN],        
    _params: Bytes[MAX_PARAMS_LEN],
    _referral_code: Bytes[2]
):
    """
    @notice Make flash loan call to pool
    @dev Uses raw_call, since uint16 is not supported in vyper
    @param _assets Address of asset to borrow
    @param _amounts Amount of asset to borrow (raw)
    @param _params Arbitrary params to pass to the receiver
    @param _referral_code Optional Aave referral code
    """
    receiver_address: address = self
    on_behalf_of: address = self

    raw_call(
        FLASH_POOL,
        _abi_encode(
            receiver_address,
            _assets,
            _amounts,
            _interest_rate_modes,
            on_behalf_of,
            _params,
            _referral_code,
            method_id=method_id("flashLoan(address,address[],uint256[],uint256[],address,bytes,uint16)")
        )
    )

@external
def flash_call(
    _assets: DynArray[address, MAX_ASSETS_LEN],
    _amounts: DynArray[uint256, MAX_ASSETS_LEN],
    _interest_rate_modes: DynArray[uint256, MAX_ASSETS_LEN],        
    _params: Bytes[MAX_PARAMS_LEN],
    _referral_code: Bytes[2]
):

    self._flash_call(_assets, _amounts, _interest_rate_modes, _params, _referral_code)
    
@external
def approve(token: address):
    ERC20(token).approve(FLASH_POOL, MAX_UINT256)

@external
@view
def yfi_buyer_price() -> uint256:
    oracle: ChainlinkRound = Chainlink(YFI_USD).latestRoundData()
    if (oracle.updatedAt + STALE_AFTER > block.timestamp):
       return convert(oracle.answer, uint256) * 10 ** 10
    else:
        return 0

@external
def dump_yfi():
    univ3_pool(YFI_ETH_V3_POOL).swap(self, True, convert(ERC20(YFI).balanceOf(self), int256), MIN_SQRT_RATIO, b"")
    # ERC20(YFI).transfer(YFI_ETH_v2_POOL, ERC20(YFI).balanceOf(self))
    # univ2_pool(YFI_ETH_v2_POOL).swap(0, 10**20, self, b"")
    # univ2_pool(YFI_ETH_v2_POOL).skim(self)

@external
def uniswapV3SwapCallback(amount0Delta: int256, amount1Delta: int256, data: Bytes[1024]):
    assert amount0Delta > 0 or amount1Delta > 0
    tokenIn: address = 0x0000000000000000000000000000000000000000
    tokenOut: address = 0x0000000000000000000000000000000000000000
    fee: uint24 = 0 
    amount_to_pay: uint256 = 0
    zeroForOne: bool = False

    if (amount0Delta > 0):
       zeroForOne = True
       amount_to_pay = convert(amount0Delta, uint256)
    else:
        amount_to_pay = convert(amount1Delta, uint256)

    if (msg.sender == YFI_ETH_V3_POOL):
       if (zeroForOne):
          tokenIn = YFI
          tokenOut = WETH
          fee = 3000
       else:
          tokenIn = WETH
          tokenOut = YFI
          fee = 3000
        
    elif (msg.sender == DAI_ETH_V3_POOL):
       tokenIn = DAI
       tokenOut = WETH
       fee = 500
    else:
        raise

    ERC20(tokenIn).transfer(msg.sender, amount_to_pay)

@external
def check():
    amountIn: uint256 = yfi_buyer(YFI_BUYER).max_amount()
    self._flash_call([YFI], [amountIn], [0], b"", b"")
    
