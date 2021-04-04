import React from "react";
import { Navbar, NavItem, Container } from "react-bootstrap";

export default function NavBar(props) {
  return (
    <header>
      <Navbar expand="lg" variant="light" bg="light">
        <Container fluid>
          <Navbar.Brand href="">Cobalt Lend Treasury</Navbar.Brand>
          <NavItem ><button className="buttonMid" style={{
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
          <NavItem className="metaacct">Meta Mask Account: {props.account}</NavItem>
        </Container>
      </Navbar>
    </header>
  );
}
