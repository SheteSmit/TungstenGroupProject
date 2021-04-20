import './swap.css';
import styled from 'styled-components';
export default function Container({ children }) {
  return (
    <SwapWrapper>
      <SwapCard>{children}</SwapCard>
    </SwapWrapper>
  );
}

const SwapWrapper = styled.div`
  margin-top: 10%;
  display: flex;
  justify-content: center;
`;

const SwapCard = styled.div`
  background: white;
  border-radius: 12px;
  height: auto;
  width: 60vw;
  padding: 2% 1%;
`;
