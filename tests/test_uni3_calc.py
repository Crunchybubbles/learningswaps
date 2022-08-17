# import pytest

# @pytest.fixture
# def get_weth(accounts, Contract):
#     weth = Contract("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
#     weth.deposit({"from": accounts[1], "value": (accounts[1].balance * 99) / 100})
#     weth.transfer(accounts[0], weth.balanceOf(accounts[1]), {"from": accounts[0]})

# def test_get_weth(accounts, Contract):
#     weth = Contract("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
#     assert weth.balanceOf(accounts[0]) == 0
#     get_weth(accounts, Contract)
#     assert weth.balanceOf(accounts[0]) != 0
