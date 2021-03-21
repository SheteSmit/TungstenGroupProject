import React from "react";
import { Navbar, NavItem, Container } from "react-bootstrap";

export default function NavBar(props) {
  return (
    <header>
      <Navbar expand="lg" variant="light" bg="light">
        <img className="logo" src="https://i.imgur.com/yDxQ7CZ.png" />
        <Container>
          <Navbar.Brand href="#">Token Faucet</Navbar.Brand>
          <NavItem>Account: {props.account}</NavItem>
        </Container>
      </Navbar>
    </header>
  );
}
