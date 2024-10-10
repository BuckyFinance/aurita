import React, { useMemo } from 'react';
import { Spin } from 'antd';
import { LoadingOutlined } from '@ant-design/icons';

const MemoizedSpin = React.memo(({ indicator }) => (
  <Spin indicator={indicator} />
));

const App = () => {
  const indicator = useMemo(
    () => <LoadingOutlined style={{ fontSize: 96 }} spin />,
    []
  );

  return (
    <div>
      <MemoizedSpin indicator={indicator} />
    </div>
  );
};

export default App;
