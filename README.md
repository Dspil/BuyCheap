# BuyCheap
Addon for World of Warcraft 3.3.5 to find the best combination of auctions to buyout for purchasing a given amount of items.

Adds a button at the Auction House frame with an editbox directly below it for adding the desired quantity. 

## Usage

* Enter the item name in the default field on the Auction House Browse frame.
* Enter the desired quantity in the custom edit box below the "Best Price" button.
* Press the "Best Price" button.

You can cancel the procedure any time you desire. You will be promted before every auction the addon thinks you need to buyout. This cannot be avoided since patch 2.0.

## Algorithm

In order to find the best combination, the dynamic programming solution of 0-1 knapsack problem is used (with some alterations since we need to fully fill the knapsack and minimize the price) 

## Installation
To use, clone the repo in your <path_to_wow>/Interface/Addons folder.\
If you choose to download zip, extract it in <path_to_wow>/Interface/Addons. Make sure to rename the addon folder from BuyCheap-master to BuyCheap.

## Authors
  
  * Danai Efstathiou ([danaiefst](https://github.com/danaiefst))
  * Dionysios Spiliopoulos ([Dspil](https://github.com/Dspil))
