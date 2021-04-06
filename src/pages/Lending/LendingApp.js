import { useState, useEffect, useContext } from "react";
import { GlobalState } from "../../GlobalState";

const LendingApp = () => {
  const state = useContext(GlobalState);
  console.log(state.account, "hits it ");
  return <div>Hello</div>;
};

export default LendingApp;
