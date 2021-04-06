import React, { Component } from "react";
import { BrowserRouter, Switch, Route } from "react-router-dom";
import Error from "./pages/NotFound/NotFound";
import Home from "./pages/Main/homepage";
import Loader from "./pages/Loading/Loading";
import ComingSoon from "./pages/ComingSoon/ComingSoon";
import "./App.css";
import { DataProvider } from "./GlobalState";

import { Alert } from "react-bootstrap";
import Lending from "./pages/Lending/Lending";

export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loading: true,
    };
  }
  componentDidMount() {
    // this simulates an async action, after which the component will render the content
    demoAsyncCall().then(() => this.setState({ loading: false }));
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
              <Route exact path="/testing" render={() => <Home />} />
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
