import styled from 'styled-components';
import Container from '../../components/Container';
import { useForm } from 'react-hook-form';

export default function Bank() {
  const { register, handleSubmit } = useForm();
  async function submit(data) {
    switch (data.action) {
      case 'deposit': {
      }
      case 'withdraw': {
      }
      default:
        return;
    }
  }
  return (
    <Container>
      <form onSubmit={handleSubmit(submit)}>
        <input
          className="form-input"
          type="number"
          placeholder="0.0"
          {...register('amount')}
        />
        <select {...register('action')}>
          <option value="withdraw">Withdraw</option>
          <option value="deposit">Deposit</option>
        </select>
      </form>
    </Container>
  );
}
