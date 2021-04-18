/* eslint-disable */
import Web3 from 'web3';
import Bank from './abis/Bank.json';
import CHC from './abis/CHCToken.json';
import Wood from './abis/WoodToken.json';
import Smit from './abis/SmitCoin.json';
import Slick from './abis/Token.json';
import Ham from './abis/HAM.json';
import Chromium from './abis/Chromium.json';
import { useState, useEffect } from 'react';
import Swap from './components/swap';
import Router from './components/Router/Router';
import { Link } from 'react-router-dom';

export default function NewApp() {
  const [account, setAccount] = useState(null);
  const [stateWeb3, setWeb3] = useState(null);
  const [sToken, setToken] = useState(null);
  const [sCoinAddress, setCoinAddress] = useState(null);
  const [balance, setBalance] = useState(null);
  const [allContracts, setAllContracts] = useState(null);

  const abiArr = [Bank, CHC, Wood, Slick, Ham, Smit, Chromium];
  useEffect(() => {
    async function callData() {
      await loadBlockchainData();
    }
    callData();
  }, []);
  async function loadBlockchainData(dispatch) {
    if (typeof window.ethereum !== 'undefined') {
      const web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
      const netId = await web3.eth.net.getId();
      const accounts = await web3.eth.getAccounts();

      if (typeof accounts[0] !== 'undefined') {
        const bal = await web3.eth.getBalance(accounts[0]);
        setAccount(accounts[0]);
        setWeb3(web3);
      } else {
        window.alert('Please login with MetaMask');
      }

      //load contracts
      try {
        const token = new web3.eth.Contract(
          Bank.abi,
          Bank.networks[netId].address
        );
        const coinAddress = CHC.networks[netId].address;
        setToken(token);
        setCoinAddress(coinAddress);
        await token.methods
          .balanceOf()
          .call({ from: accounts[0] })
          .then((result) => {
            console.log(result.toString());
            setBalance(result.toString());
          });
        const tempContractArr = [];
        for (let i = 0; i < abiArr.length; i++) {
          tempContractArr.push(
            new web3.eth.Contract(
              abiArr[i].abi,
              abiArr[i].networks[netId].address
            )
          );
        }
        setAllContracts(tempContractArr);
      } catch (e) {
        console.log('Error', e);
        window.alert('Contracts not deployed to the current network');
      }
    } else {
      window.alert('Please install MetaMask');
    }
  }
  return (
    <div>
      <Router>
        <Link to="/">Bank</Link>
        <Link to="/swap">Exchange</Link>
      </Router>
    </div>
  );
}

async function getToken(str) {
  switch (str) {
    case 'CHC':
      return CHC;
    case 'Wood':
      return Wood;
    case 'Slick':
      return Slick;
  }
}
