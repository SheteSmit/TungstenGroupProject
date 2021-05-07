import { useState, useEffect, useContext } from "react";
import { GlobalState } from "../../GlobalState";

const LendingApp = () => {
  const state = useContext(GlobalState);
  console.log(state.account, "hits it but it doesnt register ");

  if (state.loading == true) {
    return <div>Loading</div>;
  }

  return (
    <>
      <div>The account number is {state.account}</div>
    </>
  );
};

export default LendingApp;
