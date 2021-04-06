import React, { Component } from "react";
import "./homepage.scss";
import Web3 from "web3";
import CHC from "../../abis/CHCToken.json";
import Wood from "../../abis/WoodToken.json";
import Smit from "../../abis/SmitCoin.json";
import Slick from "../../abis/Token.json";
import Ham from "../../abis/HAM.json";
import Bank from "../../abis/Bank.json";
import Chromium from "../../abis/Chromium.json";
import NavBar from "../../components/navBar";
import { Alert } from "react-bootstrap";
import { Updater } from "../../components/updater";
import Tour from "reactour";
import { disableBodyScroll, enableBodyScroll } from "body-scroll-lock";
// import { tourConfig } from '../../components/tour';
import Contract from "web3-eth-contract";
import Swap from "../../components/swap";

class Home extends Component {
  async componentWillMount() {
    await this.loadBlockchainData();
    console.log(this.state.allContracts);
    await this.cobaltBalance();
    // console.log(this.state.cblt)
  }

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
    const Token = this.state.abiArr[event.target.value];
    // creates a new web3 service
    const web3 = new Web3(window.ethereum);
    // gets networkId
    const netId = await web3.eth.net.getId();
    // creates contract
    const token = await new web3.eth.Contract(
      Token.abi,
      Token.networks[netId].address
    );

    if (this.state.abiArr[event.target.value].contractName != "Bank") {
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

    console.log(this.state);

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
    console.log(token);

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
    if (this.state.token !== "undefined") {
      try {
        const response = await this.state.allContracts[6].methods
          .testCall()
          .call({
            from: this.state.account,
          })
          .then((result) => {
            console.log(result);
          });
      } catch (e) {
        console.log("Error, deposit: ", e);
      }
    }
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

  constructor(props) {
    super(props);
    this.state = {
      web3: "undefined",
      account: "",
      token: null,
      result: "null",
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
  }

  render() {
    const { isTourOpen } = this.state;
    const accentColor = "#49bcf8";
    const tourConfig = [
      {
        selector: ".metaacct",
        content: `This is your Meta Mask Account you are currently using. Please make sure you verify your account before making transaction.`,
      },
      {
        selector: ".form-field",
        content: `Enter the amount you would like to borrow, repay on a loan, make a deposit, widthdraw or donate.`,
      },
      {
        selector: "#cusSelectbox",
        content: `Find the token you want to handle here. Keep in mind once you select the button the transaction will begin.`,
      },
      {
        selector: ".walletActions",
        content:
          "Here is where the action is. You can borrow from the liquidity pool, repay a loan, deposit to the liquidity pool, withdraw your funds, or donate to Colbalt. ",
      },
      {
        selector: "#balanceNumber",
        content:
          "Visibility is important, monitor your balance of your selected token.",
      },
      {
        selector: "#contractAddress",
        content: () => (
          <div>
            Add the token of your choice straight into your Meta Mask wallet
            with a click of the button.
            <br />
            <hr />
            <h6 style={{ textAlign: "center" }}> "Think you got it now?" </h6>
            <button
              style={{
                border: "1px solid #f7f7f7",
                background: "none",
                padding: ".3em .7em",
                fontSize: "inherit",
                display: "block",
                cursor: "pointer",
                margin: "1em auto",
              }}
              onClick={this.closeTour}
            >
              Let's Begin
            </button>
          </div>
        ),
      },
    ];

    return (
      <>
        <Tour
          onRequestClose={this.closeTour}
          steps={tourConfig}
          isOpen={isTourOpen}
          maskClassName="mask"
          className="helper"
          rounded={5}
          accentColor={accentColor}
          onAfterOpen={this.disableBody}
          onBeforeClose={this.enableBody}
        />

        <NavBar
          cobalt={this.state.cobalt}
          balance={this.state.balance}
          symbol={this.state.symbol}
          openTour={this.openTour}
          account={this.state.account}
        />

        <button onClick={this.testOracle.bind(this)}>ORACLE</button>
        <Swap balance={this.state.balance} symbol={this.state.symbol} />
        <div className="container">
          <div className="mainContent">
            <div className="mt-5">
              <img
                className="logo"
                src="https://miro.medium.com/max/4800/1*-k-vtfVGvPYehueIfPRHEA.png"
              />
            </div>
            <div>
              <div className="form-group">
                <input
                  className="form-field"
                  type="email"
                  placeholder="Amount"
                  onChange={(e) => {
                    this.setState({
                      input: e.target.value,
                    });
                  }}
                ></input>
                {/* <span className="coinInputText">{this.state.tokenName}</span> */}
                <select
                  className="choices"
                  type="select"
                  onChange={this.changeToken.bind(this)}
                  id="cusSelectbox"
                >
                  <option value="0">ETH</option>
                  <option value="1">CHC</option>
                  <option value="2">Wood</option>
                  <option value="3">Slick</option>
                  <option value="4">HAM</option>
                  <option value="5">Smit</option>
                </select>
              </div>
            </div>

            <div className="walletActions">
              <div>
                <button
                  className="buttonStart"
                  type="button"
                  onClick={this.borrow.bind(this)}
                  disabled={this.state.tokenName == "Bank"}
                >
                  Borrow
                </button>

                <button
                  className="buttonMid"
                  type="button"
                  onClick={this.sendAmount.bind(this)}
                  disabled={this.state.tokenName == "Bank"}
                >
                  Repay Loan
                </button>
              </div>
              <div>
                <button
                  className="buttonMid"
                  type="button"
                  onClick={this.depositBank.bind(this)}
                >
                  Deposit
                </button>
                <button
                  className="buttonMid"
                  type="button"
                  onClick={this.withdrawBank.bind(this)}
                >
                  Withdraw
                </button>
                <button
                  className="buttonEnd"
                  type="button"
                  onClick={this.donateBank.bind(this)}
                >
                  Donate
                </button>
              </div>
            </div>
            <div className="contractInfo mt-2">
              <div className="bottomBar">
                <span className="choices" id="balance">
                  <p className="balanceText">Balance</p>
                </span>
                <span className="form-field" id="balanceNumber">
                  {(this.state.balance / 1000000000000000000).toString() +
                    " " +
                    this.state.symbol}
                </span>
                <span
                  className="choices"
                  id="refresh"
                  onClick={this.refreshBalance.bind(this)}
                >
                  <img
                    src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Refresh_icon.svg/1024px-Refresh_icon.svg.png"
                    className="refreshLogo"
                  ></img>
                </span>
                <span className="choices" id="contract">
                  <p className="balanceText">Contract </p>
                  <img
                    onClick={() => {
                      navigator.clipboard.writeText(this.state.coinAddress);
                    }}
                    className="clipboard"
                    src="https://i.imgur.com/e7uIP8z.png"
                  />
                </span>
                <input
                  className="form-field"
                  id="contractAddress"
                  value={this.state.coinAddress}
                ></input>
                <span
                  className="choices"
                  id="refresh"
                  onClick={this.refreshBalance.bind(this)}
                >
                  <img
                    onClick={this.addToken.bind(this)}
                    src="https://cdn.iconscout.com/icon/free/png-512/metamask-2728406-2261817.png"
                    className="refreshLogo"
                  ></img>
                </span>
                {/* <p
                  onClick={() => {
                    navigator.clipboard.writeText(this.state.coinAddress);
                  }}
                  href="#"
                  id="pointer"
                >
                  {this.state.coinAddress}{" "}
                  <button onClick={this.addToken.bind(this)}>
                    MetaMask Token
                  </button>
                  <img
                    className="clipboard"
                    src="https://i.imgur.com/e7uIP8z.png"
                  />
                </p> */}
              </div>
              <div></div>
              <div className="accountBalance">
                <div style={{ fontSize: ".8rem" }}>
                  <Alert variant="warning">
                    Balance cannot be seen until tokens are added in{" "}
                    <Alert.Link href="https://metamask.io/">
                      MetaMask
                    </Alert.Link>
                  </Alert>
                  <Alert variant="danger">
                    Please add the token to your{" "}
                    <Alert.Link href="https://metamask.io/">wallet</Alert.Link>{" "}
                    to see transactions
                  </Alert>
                </div>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }
}

export default Home;
