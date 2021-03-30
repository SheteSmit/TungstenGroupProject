import React, { Component } from "react";
import "./homepage.scss";
import Web3 from "web3";
import CHC from "../../abis/CHCToken.json";
import Wood from "../../abis/WoodToken.json";
import Smit from "../../abis/SmitCoin.json";
import Slick from "../../abis/Token.json";
import Ham from "../../abis/HAM.json";
import Bank from "../../abis/Bank.json";
import NavBar from "../../components/navBar";
import { Alert } from "react-bootstrap";
import { Updater } from "../../components/updater";

class Home extends Component {
  async componentWillMount() {
    await this.loadBlockchainData();
    console.log(this.state.allContracts);
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
          .balanceOf(this.state.account)
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

    if (this.state.tokenName == Bank) {
      await this.state.token.methods
        .balanceOf("ETH")
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
        .balanceOf("ETH")
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

  constructor(props) {
    super(props);
    this.state = {
      web3: "undefined",
      account: "",
      token: null,
      result: "null",
      balance: 0,
      balances: [],
      input: 0,
      symbol: "ETH",
      tokenName: "Bank",
      abiArr: [Bank, CHC, Wood, Slick, Ham, Smit],
      allContracts: [],
      ready: false,
    };
  }

  render() {
    return (
      <>
        <NavBar account={this.state.account} />
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
