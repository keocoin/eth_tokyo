import * as React from "react";
import { usePrepareContractWrite, useContractWrite } from "wagmi";
import abi from "../../abi.json";

function Subscription() {
  const { config } = usePrepareContractWrite({
    address: `0x${process.env.CONTRACT_ADDRESS}`,
    abi: abi,
    functionName: "subscription",
    args: [1, process.env.AUTO_RENEW_DEFAULT],
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

export default Subscription;
