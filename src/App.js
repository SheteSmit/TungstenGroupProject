import React, { Component } from "react";
import "./App.css";
import Web3 from "web3";
import CHC from "./abis/CHCToken.json";
import Wood from "./abis/WoodToken.json";
import Smit from "./abis/SmitCoin.json";

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
      token: token,
      coinAddress: coinAddress,
    });
  }

  async sendAmount() {
    const amount = 10000;
    const response = await this.state.token.methods
      .donate(this.state.account, 10000)
      .send({ from: this.state.account, value: amount.toString() });
    this.setState({
      response: response,
    });
  }

  async borrow() {
    const amount = 10000;
    const response = await this.state.token.methods
      .borrow(this.state.account, amount)
      .send({ value: amount.toString(), from: this.state.account });
    this.setState({
      response: response,
    });
  }

  async balance() {
    await this.state.token.methods
      .balanceOf(this.state.account)
      .call({ from: this.state.account }, function (error, result) {
        console.log(result.toString());
      });
  }

  stateShow() {
    console.log(this.state.token.options.address);
  }

  constructor(props) {
    super(props);
    this.state = {
      web3: "undefined",
      account: "",
      token: null,
      result: "null",
      balance: 0,
      tokens: [CHC],
    };
  }

  render() {
    return (
      <div>
        <button onClick={this.borrow.bind(this)}>BORROW</button>
        <button onClick={this.sendAmount.bind(this)}>RETURN</button>
        <button onClick={this.balance.bind(this)}>GET BALANCE</button>
        <button onClick={this.stateShow.bind(this)}>State</button>
        <button onClick={this.changeToken.bind(this, Wood)}>Wood Token</button>
        <button onClick={this.changeToken.bind(this, Smit)}>Smit Token</button>
        <button onClick={this.changeToken.bind(this, CHC)}>CHC Token</button>
      </div>
    );
  }
}

export default App;
