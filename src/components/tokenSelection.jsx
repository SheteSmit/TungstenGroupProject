import { Modal, Button } from 'react-bootstrap';

export function MyVerticallyCenteredModal(props) {
    return (
        <Modal
            {...props}
            size="lg"
            aria-labelledby="contained-modal-title-vcenter"
            centered
        >
            <Modal.Header closeButton>
                <div>
                    <Modal.Title className="mb-2" id="contained-modal-title-vcenter">
                        Select a token
                </Modal.Title>
                    <input
                        className="form-input modalinput"
                        type="text"
                        placeholder="Search name or paste address"
                    ></input>
                </div>

            </Modal.Header>
            <Modal.Body>
                <h4>Centered Modal</h4>
                <p>
                    Cras mattis consectetur purus sit amet fermentum. Cras justo odio,
                    dapibus ac facilisis in, egestas eget quam. Morbi leo risus, porta ac
                    consectetur ac, vestibulum at eros.
          </p>
                <div className="modalbtngroup">
                    <button className="btngroup"><span>ETH</span><span>0</span></button>
                    <button className="btngroup mt-4"><span>CHC</span><span>0</span></button>
                    <button className="btngroup mt-4"><span>Wood</span><span>0</span></button>
                    <button className="btngroup mt-4"><span>Slick</span><span>0</span></button>
                    <button className="btngroup mt-4"><span>HAM</span><span>0</span></button>
                    <button className="btngroup mt-4"><span>ETH</span><span>0</span></button>
                    <button className="btngroup mt-4"><span>Smit</span><span>0</span></button>
                </div>

            </Modal.Body>
            <Modal.Footer>
                <Button onClick={props.onHide}>Close</Button>
            </Modal.Footer>
        </Modal>
    );
}