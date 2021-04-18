import { BrowserRouter, Switch, Route } from 'react-router-dom';
import Swap from '../swap.jsx';
import Bank from '../../pages/Bank/Bank';

export default function Router({ children }) {
  return (
    <BrowserRouter>
      {children}
      <Switch>
        <Route path="/swap" component={Swap} />
        <Route path="/" component={Bank} />
      </Switch>
    </BrowserRouter>
  );
}
