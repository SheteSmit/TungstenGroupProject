import { useState, useEffect } from 'react';
import Web3 from "web3";
import CHC from "../abis/CHCToken.json";
import Wood from "../abis/WoodToken.json";
import Smit from "../abis/SmitCoin.json";
import Slick from "../abis/Token.json";
import Ham from "../abis/HAM.json";

function ContractAPI() {
    const [contract, setContract] = useState([])
    const [abiArr, setAbiArr] = useState([])
    const [token, setToken] = useState([])
    const [coinAddress, setCoinAddress] = useState([])
    const [callback, setCallback] = useState(false)
    const [account, setAccount] = useState(false)
    const [balance, setBalance] = useState(false)
    const [web3, setWeb3] = useState(false)
    const [allContracts, setAllContracts] = useState(false)


    useEffect(() => {
        const loadBlockchainData = async (dispatch) => {
            if (typeof window.ethereum !== "undefined") {
                const web3 = new Web3(window.ethereum);
                await window.ethereum.enable();
                const netId = await web3.eth.net.getId();
                const accounts = await web3.eth.getAccounts();

                if (typeof accounts[0] !== "undefined") {
                    const balance = await web3.eth.getBalance(accounts[0]);
                    setAccount({ account: accounts[0] })
                    setBalance({ balance: balance })
                    setWeb3({ web3: web3 })
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
                    setToken({ token: token });
                    setCoinAddress({ coinAddress: coinAddress });

                    for (let i = 0; i < abiArr.length; i++) {
                        allContracts.push(
                            new web3.eth.Contract(
                                abiArr[i].abi,
                                abiArr[i].networks[netId].address
                            )
                        );
                    }
                } catch (e) {
                    console.log("Error", e);
                    window.alert("Contracts not deployed to the current network");
                }
            } else {
                window.alert("Please install MetaMask");
            }
        }
        loadBlockchainData()
    }, [callback, token, allContracts, coinAddress, account, balance, web3])

    return {
        contract: [contract, setContract],
        callback: [callback, setCallback],
        allContracts: [allContracts, setAllContracts],
        coinAddress: [coinAddress, setCoinAddress],
        account: [account, setAccount],
        balance: [balance, setBalance],
        web3: [web3, setWeb3]
    }


}

export default ContractAPI;