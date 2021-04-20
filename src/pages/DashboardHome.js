import styled from 'styled-components';
import { SpaceAroundRow } from '../components/styled/Dashboard';
import { Card } from '@material-ui/core';
export default function DashBoardHome() {
  return (
    <>
      <SpaceAroundRow>
        <Card>test</Card>
        <Card>test</Card>
        <Card>test</Card>
        <Card>test</Card>
      </SpaceAroundRow>
    </>
  );
}
