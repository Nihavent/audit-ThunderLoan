~350 nSLOC/complexity


# Terms

Liquidity provider: someone who deposits money into a protocol to earn interest.
- Where is the interest coming from?
  - In TSwap: fees came from users swapping
  - In Thunderloans: fees from flash loans?

# What is a flash loan? 

A flash loan is a loan that exists for exactly 1 transaction. A user can borrow any amount of assets from the protocol as long as they pay it back in the same transaction. If they don't pay it back, the transaction reverts and the loan is cancelled.



Run slither 
Run aderyn


# About


# Potential attack vectors

- getPriceInWeth - can the price be manipulated?

# Questions

- Why are we using TSwap for pricing?