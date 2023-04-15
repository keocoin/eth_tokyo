import * as React from "react";
import { usePrepareContractWrite, useContractWrite } from "wagmi";
import abi from "../abi.json";

function Renew() {
  const { config } = usePrepareContractWrite({
    address: `0x${process.env.CONTRACT_ADDRESS}`,
    abi: abi,
    functionName: "transferSubscriptionFees",
    args: [[2, 1, 3]],
  });

  const { write } = useContractWrite(config);

  return (
    <div>
      <button disabled={!write} onClick={() => write?.()}>
        Sub
      </button>
    </div>
  );
}

export default Renew;
