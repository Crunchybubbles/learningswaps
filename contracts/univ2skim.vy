# @version 0.3.3


interface UniV2Pool:
    def skim(to: address): nonpayable

@external
def off_the_top(pool: address):
    UniV2Pool(pool).skim(self)
