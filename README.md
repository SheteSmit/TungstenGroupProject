# Tungsten Group Project

Code base for the responseive web apps for [Cobalt-Lend.io](https://cobaltlend.io/) which is a a protocol on the blockchain that allows for community approved lending at minimal fees and low over head, with both the borrower and the community benefiting.

# HOW TO CONTRIBUTE

Find an [issue](https://github.com/CobaltTeamN/TungstenGroupProject/issues) and comment that you are going to handle it so we don't get duplicate effort on the same issue. If you are unable to solve the issue, let us know in the comments so someone else can take it.

Communicate through telegram communicating how your progress is going or if you need assistance on the part of the project you picked up.

# PULL REQUEST

If you clone this repo and realize you do not have permission to push directly to this repo [read more here](https://github.com/CobaltTeamN/TungstenGroupProject/issues/1) to learn how to fork and make a pull request

## Want to report a bug or issue with the website?

Use the [issues](https://github.com/CobaltTeamN/TungstenGroupProject/issues) section on this page to let us know.

## How To Contribute Code

The app is built with solidity programming language , Truffle framework , and Node.js. The teams prefence for this project will be using the IDE VScode often know as Visual Studio Code.

Solidity Resources:
Description:Solidity is a contract-oriented, high-level language for implementing smart contracts.

How to use Master Solidity:

Part 1) https://www.youtube.com/watch?v=pqxNmdwEHio

Part 2)https://www.youtube.com/watch?v=HxlxNwgoN8w

Part 3) https://www.youtube.com/watch?v=7Pm9HB-mJQg

Part 4) https://www.youtube.com/watch?v=wJnXuCFVGFA

Node.js Resources:
Description: Node. js is a runtime environment that allows software developers to launch
both the frontend and backend of web apps using JavaScript. Although JS underpins all the
processes for app assembly, as a backend development environment.

How to install Node.js in VScode:https://www.youtube.com/watch?v=sJ7nDNNpOMA

Truffle Resources :
Description:Truffle is a development environment, testing framework, and asset pipeline all rolled into one.
It is based on Ethereum Blockchain and is designed to facilitate the smooth and seamless development of DApps

What is Truffle Features : https://www.trufflesuite.com/truffle

How to use truffle: https://www.youtube.com/watch?v=k5uZdUU3mLM

How to build first Contract: https://www.youtube.com/watch?v=CgXQC4dbGUE

## What do I need to know to contribute code?

**Absolutely Critical**: JavaScript and Solidity

**Helps a lot**: Git/GitHub, React/React Native

## How to get started coding on this app

```sh
    # clone the repo
    https://github.com/CobaltTeamN/TungstenGroupProject.git

    # change your directory into the FRONTEND repo
    cd FRONT-END

    # install node modules
    npm install

    # run react-app
    # this should make http://localhost:3000 available in your web browser
    npm start
```

## Telegram

Our telegram has links to training, information on Cobalt, and industry updates speak to Michael if you are not a part of the community. We have several different groups specifically for each part of the development process.

## On project development

# Creating a Token

Setting Solidity Version:

![](https://i.imgur.com/PDtYylk.png)

- Sets version of solidity between versions 0.6.0 and 0.8.0

## Start with the variables for token Info:

![](https://i.imgur.com/HAB7xrH.png)

- Creates variables for the name of the token, the symbol, and the decimal values the token will calculate
  - Decimals should be set to 18 since that is the standard for ether
  - The symbol should correspond to the name
- Make sure to use the correct type for whatever variable you want to create. In this example it is `<string>` for all the words/symbol and `uin8` for the numbers

![](https://i.imgur.com/AAEcmff.png)

- Creates variables for the total supply of the token, the user balance, the allowed spending, and the timestamp of when the transaction occurred
  - These will be called several times throughout the contract
- The `<mapping`> command attaches the address of the user to the total balance, allowed accounts , and the timestamp (These values will be called on in later functions)

## Creating Events for Transfer, Approval, and Borrowing

![](https://i.imgur.com/vq5bIXK.png)

- Parameters:
  - `<address indexed from>`: The address sending the tokens
  - `<address indexed to>`: The address receiving the tokens
  - `<uint256 tokens/amount>`: The number of tokens being sent
  - `<address borrower>`: The address of the borrower
  - `<uint256 timestamp>`: The time the tokens were sent (so the transaction can be verified)
- Sets up the events with all some of the basic info needed to call them later on in the contract
- Transfer will be for moving tokens between accounts, Approval will authenticate the transaction, and Borrowed will be for receiving tokens from a faucet.
- These events will be called again later on in the contract

## The Constructor

![](https://i.imgur.com/3VwGqsm.png)

- The constructor sets up some of the basic values of the token
- It establishes the name, symbol, and decimals from the beginning
- It also sets the total supply of tokens and matches it to the balance of the account that created the token

## Creating Functions

### Total Supply

![](https://i.imgur.com/qz7PFtE.png)

- Sets totalSupply() as the balance of account 0 (the account that created the token)

### Balance Of

![](https://i.imgur.com/PVJyOJF.png)

- Returns the balance of tokens in the current account that is being used

### Allowance

![](https://i.imgur.com/l8iE1bj.png)

- Gives an allowance to another address in order to retrieve tokens from it.
- Returns the remaining number of tokens the spender can spend on behalf of the owner

### Approve

![](https://i.imgur.com/3NrZbmz.png)

- Approves the transfer being made, returns the number of tokens and spender

### Borrow

![](https://i.imgur.com/0nyrFTJ.png)

- Allows someone to borrow a certain number of tokens from faucet (in this case <= 100k)

### Donate

![](https://i.imgur.com/N1WGpx8.png)

- Allows someone to donate money back to the treasury, if they have a sufficient balance

### Transfer

![](https://i.imgur.com/WYrk8D3.png)

- Allows for transfers between addresses, assuming each has a sufficient balance

### Transfer From

![](https://i.imgur.com/KDeeynZ.png)

- Similar to “transfer” except it allows other contracts to handle the transfer

### Mint

![](https://i.imgur.com/2QY2r1E.png)
![](https://i.imgur.com/VVrimKM.png)

- Add these to the events at the beginning of the contract

![](https://i.imgur.com/C68KY4I.png)

- Sets up two events in the beginning which correspond to the address of the minter and the actual mint event
- Once the minter is established and approved (through passMinterRole) the Mint function will be called and more tokens will be creates
- This will add to the totalSupply established earlier.
