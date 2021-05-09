import { AppBar as MUIAppBar, Toolbar, Button } from '@material-ui/core';
import styled from 'styled-components';
import './navBar.css';

export default function AppBar(props) {
  console.log(props)
  return (
    <MUIAppBar position="static">
      <SToolbar>
        <h2>Cobalt Lend</h2>
        <div>
          <Button className="cblt">20000 CBLT </Button>
          <Button className="navbtn eth">200 ETH </Button>
          <Button className="cblt">Scoring Token </Button>
          <Button className="cblt" onClick={() => props.loadBlockchainData()} >Connect Wallet </Button>
        </div>
      </SToolbar>
    </MUIAppBar>
  );
}

const SToolbar = styled(Toolbar)`
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  h2 {
    font-weight: 800;
    margin: 0;
    font-size: 20px;
  }
  div {
    float: right;
    display: flex;
    flex-direction: row;
    button {
      span {
        white-space: no-wrap;
        padding: 2%;
      }
      white-space: nowrap;
      margin: 2% 2% 2% 2%;
      color: white;
      border-color: white;
    }
  }
`;
