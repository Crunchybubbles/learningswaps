import brownie
from brownie import Contract, accounts, interface, network, web3, chain
from brownie_tokens import MintableForkToken

UNISWAP_V2_ROUTER_02 = '0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'
WETH_ADDRESS ='0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2'
DAI_ADDRESS = '0x6B175474E89094C44Da98b954EedeAC495271d0F'
UNISWAP_LOOKUP_CONTRACT_ADDRESS = Contract('0x5EF1009b9FCD4fec3094a5564047e190D72Bd511')
DAI_WHALE = '0x82810e81CAD10B8032D39758C8DBa3bA47Ad7092'
dai = Contract('0x6B175474E89094C44Da98b954EedeAC495271d0F')
weth = Contract('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2')

# test_account = accounts.load('testacc')
test_account = accounts[0]

# def getWETH(amount):
#     WETH = MintableForkToken(WETH_ADDRESS)
#     WETH._mint_for_testing(test_account, amount)

def getDAI(amount):
    dai.transferFrom(DAI_WHALE, test_account, amount, {'from':DAI_WHALE})

def approve_ERC20(amount, to, erc20_address, myaccount):
    print(f"Approving {erc20_address}")
    erc20 = interface.IERC20(erc20_address)
    tx_hash = erc20.approve(to, amount, {'from': myaccount})
    print(f"Approved! {erc20_address}")
    tx_hash.wait(1)
    return tx_hash

def tokenbalance(account, token):
    t = interface.IERC20(token)
    return t.balanceOf(account)


def getAmountout(amountA, reserveA, reserveB):
    return amountA*977*reserveB/(reserveA*1000+amountA*977)

def minOut(amount_out):
    return amount_out-((amount_out*2)/100)

def get_Reserves(pool_list):
    reserves = UNISWAP_LOOKUP_CONTRACT_ADDRESS.getReservesByPairs(pool_list)
    reserve1 = reserves[0][0] #dai
    # print(f'reserve1 {reserve1}')
    reserve2 = reserves[0][1] #weth
    # print(f'reserve2 {reserve2}')

    return [reserve1,reserve2]


def swap(tokenIN, tokenOUT, amount, myaccount, router_address):
    # reserves = get_Reserves(['0xa478c2975ab1ea89e8196811f51a7b7ade33eb11'])
    approve_ERC20(amount, router_address, tokenIN, myaccount)
    path = ['0x6B175474E89094C44Da98b954EedeAC495271d0F', '0x49d716DFe60b37379010A75329ae09428f17118d', '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2','0x6B175474E89094C44Da98b954EedeAC495271d0F']
    # path = [tokenIN, tokenOUT]
    # amountOUTmin = minOut(getAmountout(amount, reserves[0] , reserves[1]))
    timestamp = chain[brownie.web3.eth.get_block_number()]["timestamp"] + 120
    router = interface.IUniswapV2Router02(UNISWAP_V2_ROUTER_02)
    swap_tx = router.swapExactTokensForTokens(amount, 1, path, myaccount.address, timestamp, {'from':myaccount })
    swap_tx.wait(1)
    return swap_tx


def main():
    _amount = 1000000000000000000
    # get_Reserves(['0xa478c2975ab1ea89e8196811f51a7b7ade33eb11'])
    # getblocknumber()
    # getWETH(100*10**18)
    print(tokenbalance(test_account,DAI_ADDRESS))
    getDAI(_amount)
    print(tokenbalance(test_account,DAI_ADDRESS))


    # approve_ERC20(10*10**18, UNISWAP_V2_ROUTER_02, WETH_ADDRESS, test_account)
    # tx = approve_ERC20(10*10**18, UNISWAP_V2_ROUTER_02, WETH_ADDRESS, test_account)
    # tx.wait(1)
    print(tokenbalance(test_account,WETH_ADDRESS))
    swap(DAI_ADDRESS, WETH_ADDRESS, _amount, test_account, UNISWAP_V2_ROUTER_02)
    print(tokenbalance(test_account,DAI_ADDRESS))
    print(tokenbalance(test_account,WETH_ADDRESS))
