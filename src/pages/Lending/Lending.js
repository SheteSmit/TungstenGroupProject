import Loader from "./Loader";
import { useState, useEffect, useContext } from "react";
import { GlobalState } from "../../GlobalState";
import LendingApp from "./LendingApp";

const Lending = () => {
  const state = useContext(GlobalState);
  const ready = state.account;
  return (
    <div>
      <Loader></Loader>
      <LendingApp></LendingApp>
      Hello
    </div>
  );
};

export default Lending;
