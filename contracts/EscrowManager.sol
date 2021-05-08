// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Escrow.sol";

contract EscrowManager {
    event CreatedEscrow(
        address escrow,
        address creator,
        address payee,
        uint256 createAt,
        uint256 amount
    );

    mapping(address => Escrow[]) escrows;
    address mediator;

    constructor() {
        mediator = msg.sender;
    }

    function getEscrows(address _user) external view returns (Escrow[] memory) {
        return escrows[_user];
    }

    function newEscrowContract(
        address payable _payee,
        string memory _escrowDetails,
        uint256 _priceInWei
    ) external payable returns (Escrow escrow) {
        escrow = new Escrow(
            payable(msg.sender),
            _payee,
            mediator,
            _escrowDetails,
            _priceInWei
        );

        escrows[msg.sender].push(escrow);
        escrows[_payee].push(escrow);

        payable(address(escrow)).transfer(msg.value);

        CreatedEscrow(
            address(escrow),
            msg.sender,
            _payee,
            block.timestamp,
            _priceInWei
        );
    }

    receive() external payable {
        revert();
    }
}
