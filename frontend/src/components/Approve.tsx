import * as React from "react";
import {
  usePrepareContractWrite,
  useContractWrite,
  useContract,
  erc20ABI,
  useSigner,
} from "wagmi";
import abi from "../../abi.json";

function CreateService() {
  const { data: signer } = useSigner();

  const contract: any = useContract({
    address: `0x${process.env.PAYMENT_TOKEN_ADDRESS}`,
    abi: erc20ABI,
  });

  const approveA = async () => {
    const results = await contract
      .connect(signer)
      .approve(
        `0x${process.env.CONTRACT_ADDRESS}`,
        process.env.DEFAULT_ALLOWANCE
      );

    console.log(results);
  };

  //   const { config } = usePrepareContractWrite({
  //     address: "0x8b418b51f8ab22def2e9245312f52ad1cd54c420",
  //     abi: abi,
  //     functionName: "approve",
  //     args: [1],
  //   });

  //   const { write } = useContractWrite(config);

  return (
    <div>
      <button disabled={!approveA} onClick={() => approveA?.()}>
        Approve
      </button>
    </div>
  );
}

export default CreateService;
