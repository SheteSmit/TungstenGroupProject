import React, { createContext, useState, useEffect } from "react";
import ContractAPI from "./api/contractAPI";

export const GlobalState = createContext();

export const DataProvider = ({ children }) => {
  const [useContract, setUseContract] = useState(false);

  useEffect(() => {}, []);

  const state = {
    useContract: [useContract, setUseContract],
    contractAPI: ContractAPI(useContract),
  };

  return <GlobalState.Provider value={state}>{children}</GlobalState.Provider>;
};
