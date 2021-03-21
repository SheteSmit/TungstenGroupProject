import React from 'react';
import { DropdownButton, Dropdown } from 'react-bootstrap';

export default function Dropdown(props) {
    return (
        <section>
            <DropdownButton id="dropdown-item-button" title="Dropdown button">
                <Dropdown.ItemText>Select Token</Dropdown.ItemText>
                <Dropdown.Item as="button">Action</Dropdown.Item>
                <Dropdown.Item as="button">Another action</Dropdown.Item>
                <Dropdown.Item as="button">Something else</Dropdown.Item>
            </DropdownButton>
        </section>
    )
}