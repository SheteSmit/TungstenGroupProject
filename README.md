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

# Creating a Bank

## Set Solidity Version

![](https://i.imgur.com/GJHwh4F.png)

- Sets the version of solidity to between 0.4.22 and 0.9.0

## Import Separate Contracts

![](https://i.imgur.com/dfOjQBs.png)

### Ownable.sol

![](https://i.imgur.com/STsUPql.png)

- Handles the management of the owner role, makes sure the person calling certain functions is the owner of the contract
-

### ERC20.sol

![](https://i.imgur.com/WoYQSPS.png)

- Sets the basic ERC20 Tokens standards
- In the main Bank.sol contract this helps create a dummy token that we can pass other token addresses and parameters through

### SafeMath

![](https://i.imgur.com/BCBXS2z.png)

- Helps with the simple math for the contracts, makes sure the calculations are secure
-

## Starting the contract + Constructor

![](https://i.imgur.com/mFJiM7v.png)

- We use a mapping to attach the address of the user to the loan that they will receive. This information will be put into the variable called loanBook which will record the loans being sent out.
- Constructor Parameters:
  - `<address[] memory addresses`>: stores the addresses of the allowed tokens in memory and puts them into an array
  - `<address _CBLT>`: The address for the CBLT token
- The constructor will use a for loop to assign the allowed tokens from the addresses array
- The CBLT token will be created separately since that token will always be a part of the bank/exchange

## Structs

![](https://i.imgur.com/45APvsH.png)

- Structs are used to represent a record of an object. In this case we will use structs to hold information that we need for the loans and calculating the interest rate.
- In the `<Loan>` struct, key information like the borrower’s address, the dueDate, and the collateral is held. This information can either be called later on when the user needs to view it, or can be changed if something relating to the loan is changed
- The `<Rational>` struct holds the info for the numerator and denominator. This makes it easier to calculate the interest rate which will be used several times throughout this contract.

## Events

![](https://i.imgur.com/o4Xfpgr.png)

- onReceived handles any donations to the treasury.
  - The parameters are the address of the sender, and the amount of currency being sent.
- onTransfer and depositToken handle transfers and deposits
  - The parameters are the addresses of the sender, receiver, and the amount being sent
- These events will be called later on in the contract whenever there is anything to do with donations, transfers, or receiving.

## Mappings

![](https://i.imgur.com/NXDlxiD.png)

- Sets the total balance of the owner, the list of allowed tokens, the supply of said tokens, and the current balance of ether
- Mappings attach the addresses of the user to these specified values which can be called later on in thee contract

## Functions

### withdrawTokens

![](https://i.imgur.com/qxCLrW5.png)

- Parameters:
  - `<address _tokenAddress>`: address of the specified token that is being withdrawn
  - `<uint256 _amount>`: The number amount that is being withdrawn
- This function allows the user to withdraw tokens assuming that they meet certain requirements:
  - Is the token supported? Does the user have enough in their balance? Is the number 0? The require commands will make sure that these prerequisite are met before the transaction goes through
  - The supported tokens were added in earlier on in the contract in the constructor.
- A dummy token is also created so that the parameters of the supported tokens in the treasury can pass through it.
  - If the user does not meet one of the requirements it will return “Transfer not complete”
- `<emit onTransfer>` calls the onTransfer event and actually send the tokens

### withdraw

![](https://i.imgur.com/pxN0yFz.png)

- Very similar to withdrawToken, except for ether so no dummy token needs to be created
- Just like the previous function this one also uses `<require>` to establish certain prerequisites before the transaction can go through.

### depositTokens

![](https://i.imgur.com/gzFP6CH.png)

- Parameters:
  - `<address _tokenAddress>`: address of the specified token that is being deposited
  - `<uint256 _amount>`: The number amount that is being deposited
- This function allows the user to deposit tokens assuming that the token is supported by the treasury. (Very similar to the `<withdrawTokens>` function)
  - The supported tokens were added in earlier on in the contract in the constructor.
- A dummy token is also created so that the parameters of the supported tokens in the treasury can pass through it.
  - If the user does not meet one of the requirements it will return “Transfer not complete”
- `<emit onTransfer>` calls the depositToken event and actually send the tokens

### deposit

![](https://i.imgur.com/o4302P8.png)

- A basic deposit function used for ether, similar to the withdraw function
- Since ether is an established currency we can forgo the creation of the dummy token that we use for out custom tokens

### addToken/removeToken

![](https://i.imgur.com/4CLevIk.png)

- Parameters:
  - `<address _tokenAddress>`: The address of the specified token
- First checks to see if the person who called the function has the role of owner
  - The owner role is created and specified in `<Ownable.sol>`. Only the owner can make changes as to what tokens are supported by the treasury.
- If the user is the owner, these functions will allow for the addition or removal of certain tokens from the treasury.

### totalTokenSupply

![](https://i.imgur.com/gqu3DXV.png)

- Returns the total number of a particular token by checking the balance of the contract address.

# The Lending System

## Functions

### Multiply

![](https://i.imgur.com/1cQNJ8m.png)

- Simply multiplication function

### Calculate Components

![](https://i.imgur.com/7sPuRkS.png)

- Calculates the interest and principal that the borrower has to pay/paid

### Calculate Collateral

![](https://i.imgur.com/i2jn1YZ.png)

- Calculates the collateral based on the DID’s of the borrower and the initial amount handed out

### Process Period

![](https://i.imgur.com/YMlMBrO.png)

- Used to calculate the remaining time left on the loan

### Make Payment

![](https://i.imgur.com/a2wFhcO.png)

- Function for the user to make payments on their loan
- Calculates changes in interest and principal based on the payment

### Missed Payment

![](https://i.imgur.com/auskJ2w.png)

- If the user missed a payment this function will calculate the changes in interest and principle
- Will also make sure that the user does not receive the collateral that they would have received

### Return Collateral

![](https://i.imgur.com/QQCDCQi.png)

- Sends some collateral back to the user if they make the payment on time
