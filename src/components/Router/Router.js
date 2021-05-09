import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Swap from '../exchange';
import Bank from '../../pages/Bank/Bank';
import Treasury from '../../pages/Treasury/Treasury';
import DashBoardHome from '../../pages/dashboard';
import Voting from '../../pages/Voting/Voting';
import Singlevote from '../../pages/Voting/Singlevote';
import NFT from '../../pages/NFT/NFT';

export default function Router() {
  return (
    <>
      <Switch>
        <Route exact path="/NFT" component={NFT}/> 
        <Route exact path="/singlevote" component={Singlevote}/> 
        <Route exact path="/voting" component={Voting}/> 
        <Route path="/chromium" component={Swap} />
        <Route path="/treasury" component={Treasury} />
        <Route path="/" component={DashBoardHome} />
      </Switch>
    </>
  );
}
