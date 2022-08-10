import brownie
from brownie import accounts, Contract


def main():
    dai = Contract("0x6b175474e89094c44da98b954eedeac495271d0f")
    whale = "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643"
    bal = dai.balanceOf(whale)
    dai.transfer(accounts[0], bal, {"from": whale})


    
