import React, { createContext, useState } from "react";
import ContractAPI from "./api/contractAPI";

export const GlobalState = createContext();

export const DataProvider = ({ children }) => {
  const [useContract, setUseContract] = useState(false);


  const state = {
    useContract: [useContract, setUseContract],
    contractAPI: ContractAPI(),

  };
  ContractAPI();
  return (
  <GlobalState.Provider value={state}>
    {children}
    </GlobalState.Provider>
  );
};
