import React from 'react';
import OngoingLoans from '../../components/chronicles/ongoing';
import PastHistory from '../../components/chronicles/past';
import './Chronicles.css';

const Chronicles = () => {
    return (
        <>
            <h2 className="chronicles-title">Chronicles</h2>
            <p className="chronicles-info">View the current and past projects</p>
            <div className="chronicles-group">
                <div className="ongoing-group">
                    <OngoingLoans/>
                    <OngoingLoans/>
                    <OngoingLoans/>
                    <OngoingLoans/>
                    <OngoingLoans/>
                </div>
                <div className="pasthistory-group">
                    <PastHistory/>
                    <PastHistory/>
                    <PastHistory/>
                    <PastHistory/>
                    <PastHistory/>
                </div>
            </div>
        </>
    )
}

export default Chronicles;