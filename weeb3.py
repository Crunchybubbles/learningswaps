import web3
from web3 import Web3
import json

def openjson(file_name):
    f = open(file_name)
    info = json.load(f)
    f.close()
    return info



def main():
    w3 = Web3(Web3.WebsocketProvider('wss://mainnet.infura.io/ws/v3/cb7a603124c4411ba12877599e494814'))
    vyper_router = openjson("/Users/jasper/learningswaps/build/contracts/vyper_router.json")
    bytecode = vyper_router['deployedBytecode']
    abi = vyper_router['abi']
    router = w3.eth.contract(abi=abi, bytecode=bytecode)
    contract_deploy = w3.eth.contract.constructor().build_transaction(router)
    w3.eth.call(contract_deploy)
    #print(router)




main()
