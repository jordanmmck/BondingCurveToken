# Bonding Curve token

## spec

- [ ] **Solidity contract 3:** (**hard**) Token sale and buyback with bonding curve. The more tokens a user buys, the more expensive the token becomes. To keep things simple, use a linear bonding curve. When a person sends a token to the contract with ERC1363 or ERC777, it should trigger the receive function. If you use a separate contract to handle the reserve and use ERC20, you need to use the approve and send workflow. This should support fractions of tokens.
- [ ]  Consider the case someone might [sandwhich attack](https://medium.com/coinmonks/defi-sandwich-attack-explain-776f6f43b2fd) a bonding curve. What can you do about it?
- [ ]  We have intentionally omitted other resources for bonding curves, we encourage you to find them on your own.

## math

![math](./math1.jpg)

![math](./math2.jpg)

## sandwich attacks

One possible mitigation to sandwich attacks might be to have a delay of X blocks between minting and redeeming tokens... ie. a buyer cannot redeem until 25 blocks have passed since their mint...
