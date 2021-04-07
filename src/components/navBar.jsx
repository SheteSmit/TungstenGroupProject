import React from "react";
import { Link } from 'react-router-dom'
import { Navbar, Nav, NavDropdown, NavItem, Container } from "react-bootstrap";
import "./navBar.css";

export default function NavBar(props) {
  let account = props.account;
  let length = props.account.length;
  let accountTruncatedFrist = account.substring(0, 5);
  let accountTruncatedLast = account.substring(length - 5, length);
  let accountTruncated = accountTruncatedFrist + "..." + accountTruncatedLast;
  return (
    <header>
      <Navbar className="navgroup" collapseOnSelect expand="lg">
        <Navbar.Brand href="#home" className="ml-2">
          <img
            width="50px"
            src="https://miro.medium.com/max/4800/1*-k-vtfVGvPYehueIfPRHEA.png"
          />
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="responsive-navbar-nav" />
        <Navbar.Collapse id="responsive-navbar-nav">
          <Nav className="mr-auto ">

            <Nav.Item><Link to='/swap'>Swap</Link></Nav.Item>
            <Nav.Item><Link to='/lending'>Loan</Link></Nav.Item>
            <Nav.Item ><Link to='/treasury'>Treasury</Link></Nav.Item>
            <Nav.Item><Link to='/voting'>Vote</Link></Nav.Item>
          </Nav>
          <Nav className="justify-content-end align-items-center">
            <Nav.Link href="#deets">
              <button className="navbtn tour" onClick={props.openTour}>
                Take A Tour
              </button>
            </Nav.Link>

            <Nav.Link href="#memes">
              {" "}
              <button className="cblt">
                <span>{props.cobalt + " CBLT"}</span>
              </button>
            </Nav.Link>
            <Nav.Link href="#memes">
              {" "}
              <button className="navbtn ">
                <span>
                  {(props.balance / 1000000000000000000).toString() +
                    " " +
                    " " +
                    props.symbol}
                </span>
              </button>
            </Nav.Link>
            <Nav.Link href="#memes">
              {" "}
              <button
                onClick={() => {
                  navigator.clipboard.writeText(account);
                }}
                className="navbtn eth"
              >
                {accountTruncated.toUpperCase()}
              </button>
            </Nav.Link>
            <NavDropdown
              className="navbtn settings mr-2"
              title="..."
              id="collasible-nav-dropdown"
            >
              <NavDropdown.Item href="#action/3.2"></NavDropdown.Item>
              <NavDropdown.Item href="#action/3.2"></NavDropdown.Item>
              <NavDropdown.Divider />
              <NavDropdown.Item href="#action/3.4">
                Separated link
              </NavDropdown.Item>
            </NavDropdown>
          </Nav>
        </Navbar.Collapse>
      </Navbar>
    </header>
  );
}
