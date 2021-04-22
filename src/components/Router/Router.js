import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Swap from '../swap.jsx';
import Bank from '../../pages/Bank/Bank';
import DashBoardHome from '../../pages/DashboardHome';
export default function Router({ children }) {
  return (
    <>
      {children}
      <Switch>
        <Route path="/chromium" component={Swap} />
        <Route path="/" component={DashBoardHome} />
      </Switch>
    </>
  );
}
