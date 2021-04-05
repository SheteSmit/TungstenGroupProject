import React from "react";
import { Navbar, Nav, NavDropdown, NavItem, Container } from "react-bootstrap";

export default function NavBar(props) {
  let account = props.account
  let length = props.account.length;
  let accountTruncatedFrist = account.substring(0, 5);
  let accountTruncatedLast = account.substring(length - 5, length);
  let accountTruncated = accountTruncatedFrist + "..." + accountTruncatedLast
  return (
    <header>
      <Navbar collapseOnSelect expand="lg" bg="dark" variant="dark">
        <Navbar.Brand href="#home" className="ml-2" >
          <img width="50px"
            src="https://miro.medium.com/max/4800/1*-k-vtfVGvPYehueIfPRHEA.png"
          />
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="responsive-navbar-nav" />
        <Navbar.Collapse id="responsive-navbar-nav">
          <Nav className="mr-auto">
            <Nav.Link href="#swap">Swap</Nav.Link>
            <Nav.Link href="#treasury">Treasury</Nav.Link>
            <Nav.Link href="#vote">Vote</Nav.Link>
          </Nav>
          <Nav className="justify-content-end align-items-center">
            <Nav.Link href="#deets"><button className="" style={{
              border: "1px solid #f7f7f7",
              borderRadius: '12px',
              background: "#49bcf8",
              color: "white",
              fontSize: "14px",
              display: "block",
              cursor: "pointer",
              margin: "1em auto"
            }}
              onClick={props.openTour}>
              Take A Tour
      </button>
            </Nav.Link>

            <Nav.Link href="#memes"> <button style={{
              border: "1px solid #49bcf8",
              borderRadius: '12px',
              background: "#fff",
              color: "black",
              fontSize: "14px",
              display: "block",
              cursor: "pointer",
              margin: "1em auto"
            }}><span>
                {props.cobalt + " CBLT"}
              </span></button></Nav.Link>
            <Nav.Link href="#memes"> <button style={{
              border: "1px solid #49bcf8",
              borderRadius: '12px',
              background: "#fff",
              color: "black",
              fontSize: "14px",
              display: "block",
              cursor: "pointer",
              margin: "1em auto"
            }}><span>
                {(props.balance / 1000000000000000000).toString() +
                  " " + " " +
                  props.symbol}
              </span></button></Nav.Link>
            <Nav.Link href="#memes"> <button style={{
              border: "1px solid #49bcf8",
              borderRadius: '12px',
              background: "#fff",
              color: "black",
              fontSize: "14px",
              display: "block",
              cursor: "pointer",
              margin: "1em auto"
            }}>{accountTruncated.toUpperCase()}</button></Nav.Link>
            <NavDropdown className="mr-2" title="Settings" id="collasible-nav-dropdown">
              <NavDropdown.Item href="#action/3.2"></NavDropdown.Item>
              <NavDropdown.Item href="#action/3.2"></NavDropdown.Item>
              <NavDropdown.Divider />
              <NavDropdown.Item href="#action/3.4">Separated link</NavDropdown.Item>
            </NavDropdown>
          </Nav>
        </Navbar.Collapse>
      </Navbar>


    </header>
  );
}
