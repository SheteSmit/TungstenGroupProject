// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import './interfaces/SafeMath.sol';
import './interfaces/Ownable.sol';
import './interfaces/UniversalERC20.sol';

contract EscrowManager is Ownable {
    using UniversalERC20 for IERC20;

    /**
     * @dev these are all the states that the job can be in.
     * JOB_CREATED_PAYMENT_DEPOSITED is when the job was created and eth deposited into contract
     * JOB_COMPLETED is when the payee confirms that the job has been JOB_COMPLETED
     * DISPUTE is when creator and payee don't agree
     * PAYMENT_SENT_PAYEE is when the creator confirms job is done and eth is sent to payee
     * PAYMENT_SENT_BACK can only be set if the job was in dispute and we think that he needs his money
     * back because the payee didn't do something correctly
    */
    enum State {JOB_CREATED_PAYMENT_DEPOSITED, JOB_COMPLETED, DISPUTE, PAYMENT_SENT_PAYEE, PAYMENT_SENT_BACK}

    // the details of the job
    struct JobInfo {
        address escrowCreator;
        address payable payee;
        string jobDetails;
        uint priceInWei;
        uint paidWei;
        bool jobCompletion;
        bool confirmJobCompletion;
        EscrowManager.State state;
    }

    // default eth address the contract is going to use
    IERC20 private constant ETH_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    // used to index each job, each job that is created will increment this by 1
    uint index;

    // mapping of the index to the job details
    mapping(uint => JobInfo) public jobs;

    /**
     * mapping of each transactions for each index/job.
     * mainly used to keep track of where the money is. if both are at 0,
     * then the funds were returned to creator after dispute.
    */
    mapping(uint => mapping(address => uint))  public transactions;

    // emits everytime the job state changes
    event JobState(uint _jobIndex, uint _state);

    // emits if there is a dispute and has to be mediated
    event JobDispute(uint _jobIndex, uint _state);

    /**
     * @dev this function will create the job and accept the deposit from the creator.
     * @param _payee is the person that is going to be paid once job is _completed
     * @param _jobDetails a description of what the job is
     * @param _priceInWei the price that is going to be deposited and paid to the payee
    */
    function createItemAndDepositFunds(address payable _payee, string memory _jobDetails, uint _priceInWei)
    external
    payable
    {
        require(msg.sender != _payee, "You can't have the same address as the payee.");
        require(msg.value != 0, "msg.value can not equal 0");
        require(_priceInWei == msg.value, "Amount deposited must equal price.");

        jobs[index].escrowCreator = msg.sender;
        jobs[index].payee = _payee;
        jobs[index].jobDetails = _jobDetails;
        jobs[index].priceInWei = _priceInWei;
        jobs[index].paidWei = msg.value;


        transactions[index][msg.sender] = msg.value;
        transactions[index][jobs[index].payee] = 0;
        jobs[index].state = State.JOB_CREATED_PAYMENT_DEPOSITED;

        emit JobState(index, uint(jobs[index].state));
        index++;
    }

    /**
     * @dev this function will allow the payee to let the creator know they have completed the job.
     * @param _index is the job index
     * @param _completed this will be true if he completed the task and false if he wants to dispute it
    */
    function jobCompletion(uint _index, bool _completed) public {
        require(jobs[_index].payee == msg.sender, "Only the payee is allowed to complete job.");
        require(jobs[_index].state == State.JOB_CREATED_PAYMENT_DEPOSITED, "Job is not at this state yet.");

        jobs[_index].jobCompletion = _completed;

        if (_completed) {
            jobs[_index].state = State.JOB_COMPLETED;
            emit JobState(_index, uint(jobs[_index].state));
        } else {
            jobs[_index].state = State.DISPUTE;
            emit JobDispute(_index, uint(jobs[_index].state));
        }

    }

    /**
     * @dev this function will allow the creator to confirm that the job is complete and then will pay the payee
     * @param _index is the index of the job
     * @param _satisfied this will be true if he is _satisfied and then the funds will be sent to the payee
     * and it will be false if he wants to dispute it.
    */
    function confirmJobCompletion(uint _index, bool _satisfied) external {
        require(jobs[_index].escrowCreator == msg.sender, "Only the job creator can confirm job completion.");
        require(jobs[_index].state == State.JOB_COMPLETED, "Job is not at this state yet.");

        if(_satisfied) {
            jobs[_index].confirmJobCompletion = _satisfied;
            ETH_ADDRESS.universalTransfer(jobs[_index].payee, jobs[_index].paidWei);
            transactions[_index][jobs[_index].escrowCreator] = 0;
            transactions[_index][jobs[_index].payee] = jobs[_index].paidWei;
            jobs[_index].state = State.PAYMENT_SENT_PAYEE;
            emit JobState(_index, uint(jobs[_index].state));
        } else {
            jobs[_index].confirmJobCompletion = _satisfied;
            jobs[_index].state = State.DISPUTE;
            emit JobDispute(_index, uint(jobs[_index].state));
        }

    }

    /**
     * @dev this function will resolve any dispute that occurs. The owner of the contract will be
     * able to talk to both parties and come up with a decision on who is correct.
     * @param _index this is the index of the job
     * @param _setState is the state that the mediator wants to put the job to
    */
    function resolveDispute(uint _index, State _setState) external onlyOwner {
        require(jobs[_index].state == State.DISPUTE, "This job is not in dispute.");

        if(_setState == State.PAYMENT_SENT_PAYEE) {
            ETH_ADDRESS.universalTransfer(jobs[_index].payee, jobs[_index].paidWei);
            transactions[_index][jobs[_index].escrowCreator] = 0;
            transactions[_index][jobs[_index].payee] = jobs[_index].paidWei;
            jobs[_index].state = State.PAYMENT_SENT_PAYEE;
            emit JobState(_index, uint(jobs[_index].state));
        } else if (_setState == State.PAYMENT_SENT_BACK) {
            ETH_ADDRESS.universalTransfer(jobs[_index].escrowCreator, jobs[_index].paidWei);
            transactions[_index][jobs[_index].escrowCreator] = 0;
            jobs[_index].state = State.PAYMENT_SENT_BACK;
            emit JobState(_index, uint(jobs[_index].state));
        } else {
            jobs[_index].state = _setState;
            emit JobState(_index, uint(jobs[_index].state));
        }
    }

}
