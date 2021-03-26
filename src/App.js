import React, { Component } from "react";
import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Error from './pages/NotFound/NotFound';
import Home from './pages/Main/homepage';
import Login from './pages/Login/login';
import Loader from './pages/Loading/Loading';
import "./App.css";

<<<<<<< HEAD
import { Alert } from "react-bootstrap";

=======
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
    if (this.state.token !== "undefined") {
      try {
        const response = await this.state.token.methods
          .donate(this.state.account, this.state.input)
          .send({
            from: this.state.account,
            value: this.state.input.toString(),
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
            value: this.state.input.toString(),
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
>>>>>>> f5d17c8e2c54bcb0147841f8255317c34c38235a

export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,

    };
  }
<<<<<<< HEAD
  componentDidMount() {
    // this simulates an async action, after which the component will render the content
    demoAsyncCall().then(() => this.setState({ loading: false }));
  }
=======

  depositBank() {
    if (this.state.token !== "undefined") {
      try {
        const response = await this.state.token.methods
          .deposit(this.state.account, this.state.input)
          .send({
            value: this.state.input.toString(),
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

  withdrawBank() {}

>>>>>>> f5d17c8e2c54bcb0147841f8255317c34c38235a
  render() {
    if (this.state.loading === true) {
      return <Loader />;
    } else {
      return (
        <>
<<<<<<< HEAD
          <BrowserRouter>
            <Switch>
              <Route
                exact
                path="/"
                render={() => (
                  <Login
                  />
                )}
              />
              <Route
                exact
                path="/home"
                render={() => (
                  <Home
                  />
                )}
              />
              <Error />
            </Switch>
          </BrowserRouter>
=======
          <button onClick={this.depositBank}>Deposit</button>
          <button onClick={this.withdrawBank}>Withdraw</button>

          <NavBar account={this.state.account} />
          <div className="container">
            <div className="mainContent">
              <div className="logo mt-5">
                <img src="https://i.imgur.com/rRTK4EH.png" />
              </div>
              <div className="walletActions mt-4">
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
                  className="btn ml-1 mr-1 btn-outline-dark"
                  onClick={this.changeToken.bind(this, Wood)}
                >
                  Wood Token
                </button>
                <button
                  type="button"
                  className="btn ml-1 mr-1 btn-outline-dark"
                  onClick={this.changeToken.bind(this, Smit)}
                >
                  Smit Token
                </button>
                <button
                  type="button"
                  className="btn ml-1 mr-1 btn-outline-dark"
                  onClick={this.changeToken.bind(this, CHC)}
                >
                  CHC Token
                </button>
                <button
                  type="button"
                  className="btn ml-1 mr-1 btn-outline-dark"
                  onClick={this.changeToken.bind(this, Ham)}
                >
                  Ham Token
                </button>
                <button
                  type="button"
                  className="btn ml-1 mr-1 btn-outline-dark"
                  onClick={this.changeToken.bind(this, Slick)}
                >
                  Slick Token
                </button>
              </div>
              <div className="contractInfo mt-2">
                <div className="bottomBar">
                  <h5>
                    The current Token Selected is {this.state.tokenName}.
                    Address of token:
                    {"  "}
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
                      <Alert.Link href="https://metamask.io/">
                        wallet
                      </Alert.Link>{" "}
                      to see transactions
                    </Alert>
                  </div>
                </div>
              </div>
            </div>
          </div>
>>>>>>> f5d17c8e2c54bcb0147841f8255317c34c38235a
        </>
      );
    }
  }
}
function demoAsyncCall() {
  return new Promise((resolve) => setTimeout(() => resolve(), 5500));
}