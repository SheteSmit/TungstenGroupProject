import { Switch, Route } from "react-router-dom";
import Swap from "../exchange";
// import Bank from '../../pages/Bank/Bank';
import DashBoardHome from "../../pages/dashboard";
import ChromiumApp from "../../pages/Exchange/ChromiumApp";
import Voting from "../../pages/Voting/Voting";
import Singlevote from "../../pages/Voting/Singlevote";
import NFT from "../../pages/NFT/NFT";
import Chronicles from "../../pages/Chronicles/Chronicles";
import Collections from "../../pages/Colletions/Collections";
import Catalyst from "../../pages/Catalyst/Catalyst";
import { DataProvider } from "../../GlobalState";

export default function Router() {
  return (
    <>
      <Switch>
        <DataProvider>
          <Route exact path="/NFT" component={NFT} />
          <Route exact path="/singlevote" component={Singlevote} />
          <Route exact path="/voting" component={Voting} />
          <Route path="/chromium" component={Swap} />
          <Route path="/hugo" component={ChromiumApp} />
          <Route path="/catalyst" component={Catalyst} />
          <Route path="/chronicles" component={Chronicles} />
          <Route path="/collections" component={Collections} />
          <Route path="/" component={DashBoardHome} />
        </DataProvider>
      </Switch>
    </>
  );
}
