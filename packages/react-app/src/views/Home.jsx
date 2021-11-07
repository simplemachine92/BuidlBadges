import React, { useCallback, useEffect, useState } from "react";
import { AddressInput } from '../components';
import { Alert, Button, Card, Col, Divider, Input, List, Menu, Row } from "antd";

    const Home = ({ readContracts,
                writeContracts,
                localProvider,
                userSigner,
                address, 
                poolAddress,
                vendorETHBalance,
                poolTokenBalance,
                yourTokenBalance,
                tokensPerEth,
                mainnetProvider,
                tokenSendToAddress,
                setTokenSendToAddress }) => {

const [approving, setApproving] = useState();

    return (
        <div>
            <Input
                    style={{ textAlign: "center" }}
                    placeholder={"amount of tokens to buy"}
                    value={tokenBuyAmount}
                    onChange={e => {
                      setTokenBuyAmount(e.target.value);
                    }}
                  />
              <Button
                    type={"primary"}
                    loading={approving}
                    onClick={async () => {
                      setApproving(true);
                      await tx(writeContracts.GTC.approve(StakingGTC, ethers.utils.parseEther
                        (tokenBuyAmount)));
                      setApproving(false);
                    }}
                  >
                    Approve
                  </Button>
        </div>
    );
}

export default Home;