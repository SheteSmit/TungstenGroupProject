import React from 'react';
import Gear from '../icons/settings.svg'
import Arrow from '../icons/arrow-down.svg'
import Down from '../icons/chevron-down.svg'
import './swap.css';

const Swap = (props) => {
    return (
        <div className="swapwrapper">
            <div className="swapcard">
                <div className="cardtitle ml-4 mr-4">
                    <h2>Swap</h2>
                    <img src={Gear} />
                </div>
                <div className="swapfrom  ml-4 mr-4">
                    <div>
                        <p>From</p>
                        <input
                            className="form-input"
                            type="number"
                            placeholder="0.0"
                            onChange={(e) => {
                                // this.setState({
                                //     input: e.target.value,
                                // });
                            }}
                        ></input>
                    </div>
                    <div>
                        <div>
                            <p className="balanceText">Balance</p>
                            <div className="form-input" >
                                {(props.balance / 1000000000000000000).toString() +
                                    " " +
                                    props.symbol}
                            </div>                        </div>
                        <select
                            className="choices"
                            type="select"
                        >
                            <option value="0">ETH</option>
                            <option value="1">CHC</option>
                            <option value="2">Wood</option>
                            <option value="3">Slick</option>
                            <option value="4">HAM</option>
                            <option value="5">Smit</option>
                        </select>
                    </div>

                </div>

                <img className="downarrow" src={Arrow} alt="" />
                <div className="swapto ml-4 mr-4">
                    <div>
                        <p>To</p>
                        <input
                            className="form-input"
                            type="number"
                            placeholder="0.0"
                            onChange={(e) => {
                                // this.setState({
                                //     input: e.target.value,
                                // });
                            }}
                        ></input>
                    </div>
                    <div>
                        <button className='swaptobtn'> <span>Select a token <img src={Down} alt="" /></span> </button>
                    </div>
                </div>
                <div className="swapbtn">
                    <button className="swapconfirmbtn mt-4">Select a token </button>
                </div>
            </div>
        </div>
    )
}

export default Swap;