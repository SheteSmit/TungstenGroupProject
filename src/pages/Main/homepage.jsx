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

class Home extends Component {
  async componentWillMount() {
    await this.loadBlockchainData();
    await this.getAllBalances();
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
        this.setState({ account: accounts[0], balance: balance, web3: web3 });
      } else {
        window.alert("Please login with MetaMask");
      }

      //load contracts
      try {
        const token = new web3.eth.Contract(
          CHC.abi,
          CHC.networks[netId].address
        );
        const coinAddress = CHC.networks[netId].address;
        this.setState({
          token: token,
          coinAddress: coinAddress,
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
    console.log(Token);
    // creates a new web3 service
    const web3 = new Web3(window.ethereum);
    // gets networkId
    const netId = await web3.eth.net.getId();
    // testing
    console.log(this.state);
    // creates contract
    const token = new web3.eth.Contract(
      Token.abi,
      Token.networks[netId].address
    );
    const coinAddress = Token.networks[netId].address;
    // all data is saved inside state to use for later
    this.setState({
      tokenName: Token.contractName,
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
  }

  async getAllBalances() {
    for (let i = 0; i < this.state.allContracts.length; i++) {
      await this.state.allContracts[i].methods
        .balanceOf(this.state.account)
        .call({ from: this.state.account })
        .then((result) => {
          console.log(result.toString());
          this.state.balances.push([
            this.state.abiArr[i].contractName,
            result.toString(),
          ]);
        });
    }
    await this.setState({
      ready: true,
    });
  }

  async sendAmount() {
    if (this.state.tokek !== "undefined") {
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
    console.log(token);

    if (this.state.token !== "undefined") {
      try {
        const response = await token.methods.deposit("ETH").send({
          value: 100000000000000000,
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

    const token = new web3.eth.Contract(Bank.abi, Bank.networks[netId].address);
    console.log(token);

    if (this.state.token !== "undefined") {
      try {
        const response = await token.methods
          .withdrawBank("ETH", "0x2170ed0880ac9a755fd29b2688956bd959f933f8")
          .send({
            value: 0.1,
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

  async balanceBank() {
    const web3 = new Web3(window.ethereum);
    const netId = await web3.eth.net.getId();

    const token = new web3.eth.Contract(Bank.abi, Bank.networks[netId].address);
    console.log(token);

    if (this.state.token !== "undefined") {
      try {
        const response = await token.methods
          .balanceOf("ETH")
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
      tokenName: "CHC",
      abiArr: [CHC, Wood, Slick, Ham, Smit],
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
            <div className="logo mt-5">
              <img src="https://i.imgur.com/rRTK4EH.png" />
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
                  <option value="0">CHC</option>
                  <option value="1">Wood</option>
                  <option value="2">Slick</option>
                  <option value="3">HAM</option>
                  <option value="4">Smit</option>
                </select>
              </div>
            </div>

            <div className="walletActions">
              <button
                type="button"
                className="btn mr-1 ml-1 btn-outline-info"
                onClick={this.borrow.bind(this)}
              >
                BORROW
              </button>
              <button
                type="button"
                className="btn ml-1 mr-1 btn-outline-info"
                onClick={this.sendAmount.bind(this)}
              >
                RETURN
              </button>
            </div>
            <button
              type="button"
              className="btn mr-1 ml-1 btn-outline-info"
              onClick={this.depositBank.bind(this)}
            >
              Deposit Ether
            </button>
            <button
              type="button"
              className="btn mr-1 ml-1 btn-outline-info"
              onClick={this.withdrawBank.bind(this)}
            >
              Withdraw Ether
            </button>

            <button
              type="button"
              className="btn mr-1 ml-1 btn-outline-info"
              onClick={this.balanceBank.bind(this)}
            >
              Balance Ether
            </button>

            <div className="contractInfo mt-2">
              <div className="bottomBar">
                <h5>
                  <p
                    onClick={() => {
                      navigator.clipboard.writeText(this.state.coinAddress);
                    }}
                    href="#"
                    id="pointer"
                  >
                    {this.state.coinAddress}{" "}
                    <img
                      className="clipboard"
                      src="https://i.imgur.com/e7uIP8z.png"
                    />
                  </p>
                </h5>
                <h5>
                  Current balance on account:{" "}
                  {this.state.balance / 1000000000000000000}{" "}
                  {this.state.tokenName}{" "}
                </h5>
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
