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
import { Alert, Table, NavItem, NavLink, } from 'react-bootstrap';

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
    if (this.state.token == null) {
      return <p>loading</p>;
    } else {
      return (
        <>
          <NavBar account={this.state.account} />
          <div className="container">

            <div className="mainContent">

              <div className="logo mt-5">
                <img src="https://i.imgur.com/rRTK4EH.png" />
              </div>
              <div className="walletActions mt-4">
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
              </div>
              <div>
                <div>
                  <input
                    className="inputAmount mt-2"
                    onChange={(e) => {
                      this.setState({
                        input: e.target.value,
                      });
                    }}
                  ></input>
                </div>
              </div>
              <div className="tokenChange mt-2">
                <button
                  type="button"
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
              </div>
              <div className="contractInfo mt-2">
                <div>

                  <h5>
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
                  </h5>
                </div>
                <div className="Account balance">
                  <div style={{ fontSize: '.8rem' }}>

                    <Alert variant='warning'>
                      Balance cannot be seen until tokens are added in  <Alert.Link href="https://metamask.io/">MetaMask</Alert.Link></Alert>
                    <Alert variant='danger'>
                      Please add the token to your  <Alert.Link href="https://metamask.io/">wallet</Alert.Link> to see transactions</Alert>
                  </div>
                </div>
                <h5>
                  Current balance on account:{" "}
                  {this.state.balance / 1000000000000000000}{" "}
                  {this.state.tokenName}{" "}
                </h5>
              </div>
            </div>
          </div>
          <div className="sidebar mt-2">
            <Table striped bordered hover>
              <thead>
                <tr>
                  <th>#</th>
                  <th>First Name</th>
                  <th>Last Name</th>
                  <th>Username</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>1</td>
                  <td>Mark</td>
                  <td>Otto</td>
                  <td>@mdo</td>
                </tr>
                <tr>
                  <td>2</td>
                  <td>Jacob</td>
                  <td>Thornton</td>
                  <td>@fat</td>
                </tr>
                <tr>
                  <td>3</td>
                  <td colSpan="2">Larry the Bird</td>
                  <td>@twitter</td>
                </tr>
              </tbody>
            </Table>
          </div>
        </>
      );
    }
  }
}

export default App;
