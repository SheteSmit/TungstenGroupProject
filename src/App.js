import React, { Component } from "react";
import "./App.css";
import Web3 from "web3";
import CHC from "./abis/CHCToken.json";
import Wood from "./abis/WoodToken.json";
import Smit from "./abis/SmitCoin.json";
import Slick from "./abis/Token.json";
import Ham from "./abis/HAM.json";
import NavBar from "./components/navBar";
import DropdownCrypto from "./components/tokenSelect";
import BtnGroupCrypto from "./components/btnGroup";
import { Nav, NavItem, NavLink, } from 'react-bootstrap';

class App extends Component {
  async componentWillMount() {
    await this.loadBlockchainData();
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
      } catch (e) {
        console.log("Error", e);
        window.alert("Contracts not deployed to the current network");
      }
    } else {
      window.alert("Please install MetaMask");
    }
    console.log(this.state);
  }

  async changeToken(Token) {
    const web3 = new Web3(window.ethereum);
    await window.ethereum.enable();
    const netId = await web3.eth.net.getId();

    const token = new web3.eth.Contract(
      Token.abi,
      Token.networks[netId].address
    );
    const coinAddress = Token.networks[netId].address;
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

  async sendAmount() {
    const amount = this.state.input * 1000000000000000000;
    const response = await this.state.token.methods
      .donate(this.state.account, amount.toString())
      .send({ from: this.state.account, value: this.state.input.toString() });
    this.setState({
      response: response,
    });
  }

  async borrow() {
    const amount = this.state.input * 1000000000000000000;
    const response = await this.state.token.methods
      .borrow(this.state.account, amount.toString())
      .send({
        value: this.state.input,
        from: this.state.account,
      });
    this.setState({
      response: response,
    });
  }

  constructor(props) {
    super(props);
    this.state = {
      web3: "undefined",
      account: "",
      token: null,
      result: "null",
      balance: 0,
      input: 0,
      tokenName: "CHC",
    };
  }

  render() {
<<<<<<< HEAD
    return (
      <>
        <NavBar account={this.state.account} />
        {/* <ButtonGroup aria-label="Basic example">

          <BtnGroupCrypto borrow={this.borrow} sendAmount={this.sendAmount}
            balance={this.balance} state={this.stateShow} />
          <DropdownCrypto borrow={this.borrow} sendAmount={this.sendAmount}
            balance={this.balance} state={this.stateShow} changeToken={this.changeToken}
            Wood={Wood} CHC={CHC} Slick={Slick} Smit={Smit} Ham={Ham} />
        </ButtonGroup> */}

        <div>
          <div className="walletActions">
            <button
              type="button"
              class="btn btn-outline-info"
              onClick={this.borrow.bind(this)}
            >
              BORROW
          </button>
            <button
              type="button"
              class="btn btn-outline-info"
              onClick={this.sendAmount.bind(this)}
            >
              RETURN
          </button>
            <button
              type="button"
              class="btn btn-outline-info"
              onClick={this.balance.bind(this)}
            >
              GET BALANCE
          </button>
=======
    if (this.state.token == null) {
      return <p>loading</p>;
    } else {
      return (
        <>
          <NavBar account={this.state.account} />
          <div className="logo">
            <img src="https://i.imgur.com/rRTK4EH.png" />
          </div>
          <div className="walletActions">
            <button
              type="button"
              class="btn mr-1 ml-1 btn-outline-info"
              onClick={this.borrow.bind(this)}
            >
              BORROW
            </button>
            <button
              type="button"
              class="btn ml-1 mr-1 btn-outline-info"
              onClick={this.sendAmount.bind(this)}
            >
              RETURN
            </button>
>>>>>>> b8a5efa32c1d1829d1d0d7c65dd92902075b1146
          </div>
          <div>
            <input
              className="inputAmount"
              onChange={(e) => {
                this.setState({
                  input: e.target.value,
                });
              }}
            ></input>
          </div>
          <div className="tokenChange">
            <button
              type="button"
<<<<<<< HEAD
              class="btn btn-outline-dark"
              onClick={this.changeToken.bind(this, Wood)}
            >
              Wood Token
          </button>
            <button
              type="button"
              class="btn btn-outline-dark"
              onClick={this.changeToken.bind(this, Smit)}
            >
              Smit Token
          </button>
            <button
              type="button"
              class="btn btn-outline-dark"
              onClick={this.changeToken.bind(this, CHC)}
            >
              CHC Token
          </button>
            <button
              type="button"
              class="btn btn-outline-dark"
              onClick={this.changeToken.bind(this, Ham)}
            >
              Ham Token
          </button>
            <button
              type="button"
              class="btn btn-outline-dark"
              onClick={this.changeToken.bind(this, Slick)}
            >
              Slick Token
          </button>
          </div>
        </div>
        <nav className="navbar fixed-bottom navbar-light" role="navigation">
          <Nav className="w-100">
            <div className=" d-flex flex-row justify-content-around w-100">

              <NavItem >
                <NavLink className="nav-link" activeClassName="active">
                  <div className="row d-flex flex-column justify-content-center align-items-center">
                    <div>Nav</div>
                  </div>
                </NavLink>
              </NavItem>
            </div>
          </Nav>
        </nav>
      </>
    );
=======
              class="btn ml-1 mr-1 btn-outline-dark"
              onClick={this.changeToken.bind(this, Wood)}
            >
              Wood Token
            </button>
            <button
              type="button"
              class="btn ml-1 mr-1 btn-outline-dark"
              onClick={this.changeToken.bind(this, Smit)}
            >
              Smit Token
            </button>
            <button
              type="button"
              class="btn ml-1 mr-1 btn-outline-dark"
              onClick={this.changeToken.bind(this, CHC)}
            >
              CHC Token
            </button>
            <button
              type="button"
              class="btn ml-1 mr-1 btn-outline-dark"
              onClick={this.changeToken.bind(this, Ham)}
            >
              Ham Token
            </button>
            <button
              type="button"
              class="btn ml-1 mr-1 btn-outline-dark"
              onClick={this.changeToken.bind(this, Slick)}
            >
              Slick Token
            </button>
            <div className="contractInfo">
              <p>
                Contract address for {this.state.tokenName} is:{"  "}
                <a
                  onClick={() => {
                    navigator.clipboard.writeText(this.state.token.address);
                  }}
                  href="#"
                  id="pointer"
                >
                  {this.state.token.address}{" "}
                  <img
                    className="clipboard"
                    src="https://i.imgur.com/e7uIP8z.png"
                  />
                </a>
              </p>
            </div>
            <div className="Account balance">
              <p>
                Current balance on account:{" "}
                {this.state.balance / 1000000000000000000}{" "}
                {this.state.tokenName}{" "}
              </p>
            </div>
          </div>
        </>
      );
    }
>>>>>>> b8a5efa32c1d1829d1d0d7c65dd92902075b1146
  }
}

export default App;
