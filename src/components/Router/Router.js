import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Swap from '../swap copy';
import Bank from '../../pages/Bank/Bank';
import DashBoardHome from '../../pages/DashboardHome';

export default function Router() {
  return (
    <>
      <Switch>
        <Route path="/chromium" component={Swap} />
        <Route path="/" component={DashBoardHome} />
      </Switch>
    </>
  );
}
