import React, { useState } from 'react';
import Gear from '../icons/settings.svg'
import Arrow from '../icons/arrow-down.svg'
import Down from '../icons/chevron-down.svg'
import { MyVerticallyCenteredModal } from './tokenSelection';
import './swap.css';

const Swap = (props) => {
    const [modalShow, setModalShow] = React.useState(false);

    return (
        <div className="swapwrapper">
            <div className="swapcard">
                <div className="cardtitle ml-4 mt-2 mb-3 mr-4">
                    <h5>Swap</h5>
                    <img src={Gear} />
                </div>
                <div className="swapfrom  ml-4 mr-4">
                    <div className="m-atuo">
                        <p>From</p>
                        <input
                            className="form-input"
                            type="number"
                            placeholder="0.0"
                            onChange={props.handleInput}
                        ></input>
                    </div>
                    <div>
                        <div className="balancediv pb-2">
                            <p >Balance</p>
                            <div className="form-input balance pl-2 " >
                                {(props.balance / 1000000000000000000).toString() +
                                    " " +
                                    props.symbol}
                            </div>
                        </div>
                        <div style={{ display: 'flex' }}>
                            <button className="tokenbtn choice" type="submit"
                                onClick={() => setModalShow(true)}>
                                {props.symbol}  <img src={Down} alt="downarrow" />
                            </button>
                            <MyVerticallyCenteredModal
                                show={modalShow}
                                onHide={() => setModalShow(false)}
                            />

                        </div>
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
                            onChange={props.handleInput}
                        ></input>
                    </div>
                    <div>
                        <button className='swaptobtn' onClick={() => setModalShow(true)}> <span>Select a token <img src={Down} alt="" /></span> </button>
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