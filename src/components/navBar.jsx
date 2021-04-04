import React from "react";
import { Navbar, Nav, NavItem, Container } from "react-bootstrap";

export default function NavBar(props) {
  return (
    <header>
      <Navbar expand="lg" variant="light" bg="light">
        <Container fluid>
          <Navbar.Brand className="ml-5" href="">Cobalt Lend Treasury</Navbar.Brand>
          <Nav className="justify-content-end align-items-center">

            <NavItem ><button className="buttonMid mr-5" style={{
              border: "1px solid #f7f7f7",
              borderRadius: '12px',
              background: "#49bcf8",
              color: "white",
              padding: ".3em .7em",
              fontSize: "inherit",
              display: "block",
              cursor: "pointer",
              margin: "1em auto"
            }}
              onClick={props.openTour}>
              Take A Tour
      </button></NavItem>
            <NavItem className="metaacct mr-5">Meta Mask Account: {props.account}</NavItem>
          </Nav>

        </Container>
      </Navbar>
    </header>
  );
}
