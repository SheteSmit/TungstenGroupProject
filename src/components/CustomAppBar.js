import {
  Drawer,
  List,
  ListItem,
  ListItemText,
  ListItemIcon,
  MenuItem,
} from '@material-ui/core';
import {
  Home,
  SwapHoriz,
  Work,
  Business,
  AccountBalance,
} from '@material-ui/icons';
import styled from 'styled-components';
import { Link, useLocation } from 'react-router-dom';
const SidebarItems = [
  { icon: <Home />, text: 'Dashboard', link: '' },
  { icon: <SwapHoriz />, text: 'Exchange', link: 'chromium' },
  { icon: <Work />, text: 'Catalyst', link: 'catalyst' },
  { icon: <Business />, text: 'SCO', link: 'sco' },
  { icon: <AccountBalance />, text: 'Lend and Borrow', link: 'lend' },
];
const StyledLink = styled(Link)`
  text-decoration: none !important;
  color: inherit;
`;

export default function CustomAppBar() {
  const location = useLocation();
  console.log(location.pathname.substr(1));

  const Lists = SidebarItems.map((item) => {
    return (
      <StyledLink to={item.link} key={item.text}>
        <ListItem
          style={{
            whiteSpace: 'normal',
            color:
              location.pathname.substr(1) === item.link ? '#5664d2' : 'inherit',
          }}>
          <ListItemIcon
            style={{
              color:
                location.pathname.substr(1) === item.link
                  ? '#5664d2'
                  : 'inherit',
            }}>
            {item.icon}
          </ListItemIcon>
          <ListItemText primary={item.text} />
        </ListItem>
      </StyledLink>
    );
  });

  return (
    <>
      <StyledDrawer variant="permanent" anchor="left">
        <img
          src="CobaltLogo.jpg"
          style={{ width: '50%', marginTop: '5%' }}
          alt="logo"
        />
        <h2>Cobalt Lend</h2>
        <StyledDivider />
        <StyledList> {Lists}</StyledList>
      </StyledDrawer>
    </>
  );
}

const StyledDrawer = styled(Drawer)`
  width: 240px;
  .MuiDrawer-paper {
    width: 240px !important;
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  margin-top: 10%;
`;
const StyledDivider = styled.hr`
  padding: 5px;
  align-self: stretch;
  margin-left: 0;
  margin-right: 0;
`;
const StyledList = styled(List)`
  width: 80%;
  margin: auto;
  border-radius: 10px;
`;
