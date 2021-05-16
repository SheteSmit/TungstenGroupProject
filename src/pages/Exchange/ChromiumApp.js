import React, {Component} from 'react'
import Web3 from 'web3'
import Chromium from '../../abis/Chromium.json'
import Oracle from '../../abis/ExchangeOracle.json'
import navBar from '../../components/navBar'
import Main from './ChromiumMain'
import {ChainId, Fetcher, Route, Trade, TokenAmount, TradeType} from '@uniswap/sdk'


class App extends Component {

    constructor(props) {
        super(props)
        this.state = {
            account: '',
            token: {},
            chromium: {},
            oracle: {},
            chainId: '',
            ethAddress: '0xc778417E063141139Fce010982780140Aa0cD5Ab',
            cbltToken: '0x433C6E3D2def6E1fb414cf9448724EFB0399b698',
            fromToken: null,
            destToken: null,
            amount: '',
            returnAmount: '',
            tokenBalance: '',
            ethBalance: '',
            uniswapQuote: '',
            loading: true
        }

        this.quote = this.quote.bind(this)
        this.swapForCblt = this.swapForCblt.bind(this)
        this.getCbltExchangeRate = this.getCbltExchangeRate.bind(this)
        this.updateToken = this.updateToken.bind(this)
    }

    async componentWillMount() {
        await this.loadWeb3()
        await this.loadBlockchainData()
    }
    async loadBlockchainData() {
        const web3 = window.web3

        const accounts = await web3.eth.getAccounts()
        this.setState({account: accounts[0]})

        const ethBalance = await web3.eth.getBalance(this.state.account)
        this.setState({ethBalance})

        // Load Token
        const networkId = await web3.eth.net.getId()
        this.setState({chainId: networkId})
        const chainId = ChainId.networkId

        const chromiumData = Chromium.networks[networkId]
        if (chromiumData) {
            const chromium = new web3.eth.Contract(Chromium.abi, chromiumData.address)
            this.setState({chromium})
        } else {
            window.alert('Chromium contract not deployed to detected network.')
        }

        const oracleData = Oracle.networks[networkId]
        if(oracleData) {
            const oracle = new web3.eth.Contract(Oracle.abi, oracleData.address)
            this.setState({oracle})
        } else {
            window.alert("Oracle contract not deployed to detected network")
        }

        this.setState({loading: false})
    }

    async loadWeb3() {
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum)
            await window.ethereum.enable()
        } else if (window.web3) {
            window.web3 = new Web3(window.web3.currentProvider)
        } else {
            window.alert('Non-Ethereum browser detected. You should consider trying MetaMask!')
        }
    }

    handleInput = (e) => {
        let name = e.target.name
        let value = e.target.value
        this.setState({
            [name]: value
        });
        console.log(name, value)
    };

    getCbltExchangeRate() {
        this.setState({loading: true})
        this.state.chromium.methods.getCbltExchangeRate(this.state.fromToken, this.state.amount).call({from: this.state.account})
            .then((results) => {
                let res = results / 1000
                this.setState({
                    returnAmount: res.toString()
                })
            })
        this.setState({loading: false})
    }

    swapForCblt() {
        this.setState({loading: true})
        let etherAmount, amountReturning
        etherAmount = this.state.amount
        etherAmount = window.web3.utils.toWei(etherAmount, "ether")
        amountReturning = this.state.returnAmount
        amountReturning = window.web3.utils.toWei(amountReturning, 'ether')
        if(this.state.fromToken === this.state.ethAddress) {
            try{
                this.state.chromium.methods.swapForCblt(this.state.fromToken, etherAmount, amountReturning).send({
                    value: etherAmount,
                    from: this.state.account
                }).on('transactionHash', (hash) => {
                    this.setState({loading: false})
                })
            } catch (e) {
                console.log("Error, deposit: ", e);
            }
        } else {
            this.state.fromToken.methods.approve(this.state.chromium.address, etherAmount).send({
                from: this.state.account
            }).on('transactionHash', (hash) => {
                this.state.chromium.methods.swapForCblt(this.state.fromToken, etherAmount, amountReturning).send({
                    from: this.state.account
                }).on('transactionHash', (hash) => {
                    this.setState({loading: false})
                })
            })
        }
    }

    async updateToken(token, name, symbol, image, value, active) {
        this.setState({loading: false})
        await this.state.oracle.methods.updateToken(token, name, symbol, image, value, active).send({
            from: this.state.account
        }).on("transactionHash", (hash) => {
            this.setState({loading: false})
        })
    }

    async quote(fromToken, destToken, amount) {
        const fToken = await Fetcher.fetchTokenData(this.state.chainId,  fromToken)
        const dToken = await Fetcher.fetchTokenData(this.state.chainId, destToken)
        const pair = await Fetcher.fetchPairData(fToken, dToken)
        const route = new Route([pair], fToken)
        const trade = new Trade(route, new TokenAmount(fToken, amount), TradeType.EXACT_INPUT)
        console.log(route.midPrice.toSignificant(6))
        console.log(trade.executionPrice.toSignificant(6))
        let uniswapQuote = trade.executionPrice.toSignificant(6)
        this.setState({uniswapQuote})
    }

    async swapExactTokensForTokens() {

    }

    render() {
        let content
        if (this.state.loading) {
            content = <p id="loader" className="text-center">Loading...</p>
        } else {
            content = <Main
                fromToken={this.state.fromToken}
                destToken={this.state.destToken}
                amount={this.state.amount}
                returnAmount={this.state.returnAmount}
                swapForCblt={this.swapForCblt}
                getCbltExchangeRate={this.getCbltExchangeRate}
                tokenBalance={this.state.tokenBalance}
                ethBalance={this.state.ethBalance}
                updateToken={this.updateToken}
                handleInput={this.handleInput}
                ethAddress={this.state.ethAddress}
                cbltToken={this.state.cbltToken}
            />
        }

        return (
            <div>
                <navBar account={this.state.account}/>
                <div className="container-fluid mt-5">
                    <div className="row">
                        <main role="main" className="col-lg-12 ml-auto mr-auto" style={{maxWidth: '600px'}}>
                            <div className="content mr-auto ml-auto">
                                <a
                                    href="http://www.dappuniversity.com/bootcamp"
                                    target="_blank"
                                    rel="noopener noreferrer"
                                >
                                </a>

                                {content}

                            </div>
                        </main>
                    </div>
                </div>
            </div>
        );
    }
}

export default App;
