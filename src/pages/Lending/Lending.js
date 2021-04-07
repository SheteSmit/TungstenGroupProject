import Loader from "./Loader";
import { useState, useEffect, useContext } from "react";
import { GlobalState } from "../../GlobalState";
import LendingApp from "./LendingApp";
import NavBar from "../../components/navBar";

const Ready = (props) => {};

const Lending = (props) => {
  const state = useContext(GlobalState);
  const ready = state.account;
  return (
    <div>
      <Loader></Loader>
      <LendingApp></LendingApp>
    </div>
  );
};

export default Lending;
