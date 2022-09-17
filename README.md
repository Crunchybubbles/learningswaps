# learningswaps

This is continuing my learning of dex arbitrage after abondoning it in ~october 2021.
This started as learning how to do swaps with univ2 pools directly and then I was reinspired to figure out uniswapV3.

In learningswaps/scripts/u3sol.py I rebuilt uniswapV3 internally in python and it almost works. It correctly calculates
swap amounts for small - medium sizes but is a fraction of a percent error off when calculating large sizes.

In learningswaps/contracts/swapcalc.sol I used parts of uniswapV3 to write a calculator for uniswapv3 swaps.

I also began learning about graph theory and became facinated with finding token swap paths throught the space of pools. I
noticed that my pathfinding algorithm was rather slow and wasnt finding all of the paths so I decided to rewrite it in rust.

