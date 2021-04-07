import React, { Component } from "react";
import { BrowserRouter, Switch, Route } from "react-router-dom";
import Error from "./pages/NotFound/NotFound";
import Home from "./pages/Main/homepage";
import Loader from "./pages/Loading/Loading";
import ComingSoon from "./pages/ComingSoon/ComingSoon";
import "./App.css";
import { DataProvider } from "./GlobalState";
import Web3 from "web3";
import CHC from "./abis/CHCToken.json";
import Wood from "./abis/WoodToken.json";
import Smit from "./abis/SmitCoin.json";
import Slick from "./abis/Token.json";
import Ham from "./abis/HAM.json";
import Bank from "./abis/Bank.json";
import Chromium from "./abis/Chromium.json";
import { Alert } from "react-bootstrap";
import Lending from "./pages/Lending/Lending";
import { disableBodyScroll, enableBodyScroll } from "body-scroll-lock";
import DIDs from "./pages/DID/DIDs";

export default class App extends Component {
  constructor() {
    super();
    this.state = {
      loading: true,
      web3: "undefined",
      account: "",
      token: null,
      result: "null",
      coinAddress: null,
      balance: 0,
      cblt: 0,
      balances: [],
      input: 0,
      symbol: "ETH",
      tokenName: "Bank",
      abiArr: [Bank, CHC, Wood, Slick, Ham, Smit, Chromium],
      allContracts: [],
      ready: false,
      isTourOpen: false,
    };

    this.changeToken = this.changeToken.bind(this);
    this.depositBank = this.depositBank.bind(this);
    this.withdrawBank = this.withdrawBank.bind(this);
    this.borrow = this.borrow.bind(this);
    this.sendAmount = this.sendAmount.bind(this);
    this.donateBank = this.donateBank.bind(this);
    this.refreshBalance = this.refreshBalance.bind(this);
    this.addToken = this.addToken.bind(this);
  }
  componentDidMount() {
    // this simulates an async action, after which the component will render the content
    demoAsyncCall().then(() => this.setState({ loading: false }));
  }

  disableBody = (target) => disableBodyScroll(target);
  enableBody = (target) => enableBodyScroll(target);

  toggleShowMore = () => {
    this.setState((prevState) => ({
      isShowingMore: !prevState.isShowingMore,
    }));
  };

  closeTour = () => {
    this.setState({ isTourOpen: false });
  };

  openTour = () => {
    this.setState({ isTourOpen: true });
  };

  handleInput = (e) => {
    this.setState({
      input: e.target.value,
    });
  };

  async loadBlockchainData(dispatch) {
    if (typeof window.ethereum !== "undefined") {
      const web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
      const netId = await web3.eth.net.getId();
      const accounts = await web3.eth.getAccounts();

      if (typeof accounts[0] !== "undefined") {
        const balance = await web3.eth.getBalance(accounts[0]);
        this.setState({ account: accounts[0], web3: web3 });
      } else {
        window.alert("Please login with MetaMask");
      }

      //load contracts
      try {
        const token = new web3.eth.Contract(
          Bank.abi,
          Bank.networks[netId].address
        );
        const coinAddress = CHC.networks[netId].address;
        this.setState({
          token: token,
          coinAddress: coinAddress,
        });
        console.log(coinAddress);
        await this.state.token.methods
          .balanceOf()
          .call({ from: this.state.account })
          .then((result) => {
            console.log(result.toString());
            this.setState({
              balance: result.toString(),
            });
          });

        for (let i = 0; i < this.state.abiArr.length; i++) {
          this.state.allContracts.push(
            new web3.eth.Contract(
              this.state.abiArr[i].abi,
              this.state.abiArr[i].networks[netId].address
            )
          );
        }
      } catch (e) {
        console.log("Error", e);
        window.alert("Contracts not deployed to the current network");
      }
    } else {
      window.alert("Please install MetaMask");
    }
  }

  async changeToken(event) {
    const Token = this.state.abiArr[event];
    // creates a new web3 service
    const web3 = new Web3(window.ethereum);
    // gets networkId
    const netId = await web3.eth.net.getId();
    // creates contract
    const token = await new web3.eth.Contract(
      Token.abi,
      Token.networks[netId].address
    );
    console.log(this);
    if (this.state.abiArr[event].contractName != "Bank") {
      await token.methods
        .symbol()
        .call()
        .then((result) => {
          this.setState({
            symbol: result,
          });
        });
    } else {
      this.setState({
        symbol: "ETH",
      });
    }

    const coinAddress = Token.networks[netId].address;
    // all data is saved inside state to use for later
    this.setState({
      tokenName: Token.contractName,
      tokenSymbol: Token.tokenSymbol,
      token: token,
      coinAddress: coinAddress,
    });

    if (this.state.tokenName == "Bank") {
      await this.state.token.methods
        .balanceOf()
        .call({ from: this.state.account })
        .then((result) => {
          console.log(result.toString());
          this.setState({
            balance: result.toString(),
          });
        });
    } else {
      await this.state.token.methods
        .balanceOf(this.state.account)
        .call({ from: this.state.account })
        .then((result) => {
          console.log(result.toString());
          this.setState({
            balance: result.toString(),
          });
        });
    }
  }

  async sendAmount() {
    if (this.state.token === Bank) {
    }
    if (this.state.token !== "undefined") {
      try {
        const response = await this.state.token.methods
          .donate(this.state.account, this.state.input)
          .send({
            from: this.state.account,
          });
        this.setState({
          response: response,
        });
      } catch (e) {
        console.log("Error, deposit: ", e);
      }
    }
  }

  async borrow() {
    if (this.state.token !== "undefined") {
      try {
        const response = await this.state.token.methods
          .borrow(this.state.account, this.state.input)
          .send({
            from: this.state.account,
          });
        this.setState({
          response: response,
        });
      } catch (e) {
        console.log("Error, deposit: ", e);
      }
    }
  }

  async depositBank() {
    const web3 = new Web3(window.ethereum);
    const netId = await web3.eth.net.getId();
    const token = new web3.eth.Contract(Bank.abi, Bank.networks[netId].address);
    const amount = this.state.input * 1000000000000000000;

    if (this.state.token !== "undefined") {
      try {
        const response = await token.methods.deposit().send({
          value: amount,
          from: this.state.account,
        });
        this.setState({
          response: response,
        });
      } catch (e) {
        console.log("Error, deposit: ", e);
      }
    }
  }

  async withdrawBank() {
    const web3 = new Web3(window.ethereum);
    const netId = await web3.eth.net.getId();
    const amount = this.state.input * 1000000000000000000;
    const token = new web3.eth.Contract(Bank.abi, Bank.networks[netId].address);
    if (this.state.token !== "undefined") {
      try {
        const response = await token.methods.withdraw(amount.toString()).send({
          from: this.state.account,
        });
        this.setState({
          response: response,
        });
      } catch (e) {
        console.log("Error, deposit: ", e);
      }
    }
  }

  async donateBank() {
    const web3 = new Web3(window.ethereum);

    if (this.state.token !== "undefined") {
      try {
        web3.eth.sendTransaction({
          from: this.state.account,
          to: this.state.coinAddress,
          value: web3.utils.toWei("0.1", "ether"),
        });
      } catch (e) {
        console.log("Error, deposit: ", e);
      }
    }
  }

  async refreshBalance() {
    if (this.state.tokenName == Bank) {
      await this.state.token.methods
        .balanceOf()
        .call({ from: this.state.account })
        .then((result) => {
          console.log(result.toString());
          this.setState({
            balance: result.toString(),
          });
        });
    } else {
      await this.state.token.methods
        .balanceOf(this.state.account)
        .call({ from: this.state.account })
        .then((result) => {
          console.log(result.toString());
          this.setState({
            balance: result.toString(),
          });
        });
    }
  }

  async cobaltBalance() {
    const address = "0x433c6e3d2def6e1fb414cf9448724efb0399b698";
    await window.ethereum
      .request({
        method: "wallet_watchAsset",
        params: {
          type: "ERC20", // Initially only supports ERC20, but eventually more!
          options: {
            address: address, // The address that the token is at.
            symbol: "CBLT", // A ticker symbol or shorthand, up to 5 chars.
            decimals: 18, // The number of decimals in the token
            image:
              "https://miro.medium.com/max/4800/1*-k-vtfVGvPYehueIfPRHEA.png", // A string url of the token logo
          },
        },
      })
      .then((success) => {
        if (success) {
          console.log(success);
          console.log("Cobalt successfully added to wallet!");
        } else {
          throw new Error("Something went wrong.");
        }
      })
      .catch(console.error);

    const web3 = new Web3(window.ethereum);
    var balance = web3.eth.getBalance(address).then((value) => {
      const credit = web3.utils.fromWei(value, "ether");
      this.setState({ cobalt: credit });
    });
  }
  async addToken() {
    const tokenAddress = this.state.coinAddress;
    const tokenSymbol = this.state.symbol;
    const tokenDecimals = 18;
    const tokenImage = "https://i.imgur.com/rRTK4EH.png";

    try {
      // wasAdded is a boolean. Like any RPC method, an error may be thrown.
      const wasAdded = await window.ethereum.request({
        method: "wallet_watchAsset",
        params: {
          type: "ERC20", // Initially only supports ERC20, but eventually more!
          options: {
            address: tokenAddress, // The address that the token is at.
            symbol: tokenSymbol, // A ticker symbol or shorthand, up to 5 chars.
            decimals: tokenDecimals, // The number of decimals in the token
            image: tokenImage, // A string url of the token logo
          },
        },
      });

      if (wasAdded) {
        console.log("Thanks for your interest!");
      } else {
        console.log("Your loss!");
      }
    } catch (error) {
      console.log(error);
    }
  }

  async testOracle() {
    // if (this.state.token !== "undefined") {
    //   try {
    //     const response = await this.state.allContracts[6].methods
    //       .testCall()
    //       .call({
    //         from: this.state.account,
    //       })
    //       .then((result) => {
    //         console.log(result);
    //       });
    //   } catch (e) {
    //     console.log("Error, deposit: ", e);
    //   }
    // }
  }

  async componentWillMount() {
    await this.loadBlockchainData();

    // await this.cobaltBalance();
    console.log(this.state);
    console.log(this.state.abiArr[1]);
  }

  render() {
    if (this.state.loading === true) {
      return <Loader />;
    } else {
      return (
        <DataProvider>
          <BrowserRouter>
            <Switch>
              <Route exact path="/" render={() => <ComingSoon />} />
              <Route exact path="/lending" render={() => <Lending />} />
              <Route exact path="/dids" render={() => <DIDs />} />
              <Route
                exact
                path="/swap"
                render={() => (
                  <Home
                    coinAddress={this.state.coinAddress}
                    web3={this.state.web3}
                    handleInput={this.handleInput}
                    deposit={this.depositBank}
                    withdrawl={this.withdrawBank}
                    changeToken={this.changeToken}
                    input={this.state.input}
                    balance={this.state.balance}
                    account={this.state.account}
                    token={this.state.token}
                    result={this.state.result}
                    cblt={this.state.cblt}
                    balances={this.state.balances}
                    symbol={this.state.symbol}
                    tokenName={this.state.tokenName}
                    abiArr={this.state.abiArr}
                    allContracts={this.state.allContracts}
                    ready={this.state.ready}
                    isTourOpen={this.state.isTourOpen}
                    testOracle={this.testOracle}
                    addToken={this.addToken}
                    cobaltBalance={this.cobaltBalance}
                    refreshBalance={this.refreshBalance}
                    donateBank={this.donateBank}
                    withdrawBank={this.withdrawBank}
                    depositBank={this.depositBank}
                    borrow={this.borrow}
                    sendAmount={this.sendAmount}
                    sendToken={this.sendToken}
                    loadBlockchainData={this.loadBlockchainData}
                    disableBody={this.disableBody}
                    enableBody={this.enableBody}
                    toggleShowMore={this.toggleShowMore}
                    closeTour={this.closeTour}
                    openTour={this.openTour}
                    handleInput={this.handleInput}
                  />
                )}
              />
              <Error />
            </Switch>
          </BrowserRouter>
        </DataProvider>
      );
    }
  }
}
function demoAsyncCall() {
  return new Promise((resolve) => setTimeout(() => resolve(), 5500));
}
