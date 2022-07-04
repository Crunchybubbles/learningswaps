from brownie import Contract, accounts
from brownie_tokens import MintableForkToken
DAI_WHALE = '0x82810e81CAD10B8032D39758C8DBa3bA47Ad7092'
dai = Contract('0x6B175474E89094C44Da98b954EedeAC495271d0F')

# def main():
#     dai_addr = "0x6b175474e89094c44da98b954eedeac495271d0f"
#     amount = 100_000 * 10 ** 18
#     dai = MintableForkToken(dai_addr)
#     dai._mint_for_testing(accounts[0], amount)


def main():
    print(dai.balanceOf(accounts[0]))
    dai.transferFrom(DAI_WHALE, accounts[0], 100*10**18, {'from':DAI_WHALE})
    print(dai.balanceOf(accounts[0]))
