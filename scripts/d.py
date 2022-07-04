import brownie
import math
from brownie import uni3data, accounts, interface


def main():
    q = uni3data.deploy({"from": accounts[0]})
    #ticks = [-201720, -203520,-203760,-204060,-205380,-205440,-205980,-206160,-206880,-206940,-207300,-208260,-208380,-208920,-209460,-209520,-209700,-210660,-210780,-211320,-211380,-211620,-211680,-212640,-213120,-214020,-214080,-214140,-214260,-214980,-215040,-215160,-215220,-215280,-216060,-216840,-217260,-217320,-218460,-219540,-220260,-220320,-220800,-220860,-220920,887220,-887220]
    addr = "0xf924e45006c9ba5ff0253f694b75e867bfbc0049"
    #r = q.pool_info([(addr, ticks)])
    #print(r)
    spacing = q.tick_spacing(addr)
    slot0 = q.get_slot0(addr)
    currentTick = slot0[1]
    currentPrice = slot0[0]

    priceUp = currentPrice + (currentPrice * 1.0001)
    print(currentPrice)
    print(priceUp)
    for i in range(100):
        print(1.0001**(-i/2))
    for i in range(100):
        print(1.0001**(i/2))
        
    
    # tickUp = math.log(priceUp, math.sqrt(1.0001))
    # print(currentTick)
    # print(tickUp)
    # tickUp = round(tickUp)
    # print(tickUp)
    # tickDiff = tickUp - currentTick
    # print(tickDiff/spacing)
    # do_another = true
    # how_many_up = 0
    # how_many_down = 0
    # while do_another:
        
    #print(tickUp - currentTick)
#    print(tickUp - currentTick / spacing)
    # tickUp = currentTick + spacing
#    tickDown = currentTick - spacing
    # for i in range(0, 30):
    #     tick = currentTick - spacing * i
    #     print(q.get_tick(addr, tick))
    # for i in range(1, 30):
    #     tick = currentTick - spacing * i
    #     print(q.get_tick(addr, tick))
#    print(q.get_slot0(addr))
 #   print(spacing, currentTick)
  #  print(q.get_tick(addr, currentTick))
