import { useState, useEffect, useContext } from "react";
import { GlobalState } from "../../GlobalState";

const LendingApp = () => {
  const state = useContext(GlobalState);
  console.log(state.account, "hits it ");
  return(<>
  <div>
    <div>
      <h2>
        Loan Title
      </h2>
        <p>Loan Description:</p>
        <a>Read More</a>
      </div>
      <div> 
        <h2> Your Loans </h2>
        <button>Create A Loan</button>
      </div>
      <div>
         <div>
        No Loan Found
          </div> 
        </div>
    </div> 
  </>
  )
};

export default LendingApp;
