import { useContract, erc20ABI, useSigner } from "wagmi";

function Approve() {
  const { data: signer } = useSigner();

  const contract: any = useContract({
    address: `0x${process.env.PAYMENT_TOKEN_ADDRESS}`,
    abi: erc20ABI,
  });

  const approvePayToken = async () => {
    const results = await contract
      .connect(signer)
      .approve(
        `0x${process.env.CONTRACT_ADDRESS}`,
        process.env.DEFAULT_ALLOWANCE
      );

    console.log(results);
  };

  return (
    <div className="px-4">
      <div className="message">
        <span>Your remining allowance for Subn is 10 USDC.</span>
      </div>
      <div className="update space-x-2">
        <input
          type="number"
          className="border p-2 px-4 w-20 rounded"
          placeholder="100"
        ></input>
        <button
          disabled={!approvePayToken}
          className={!approvePayToken ? "btn-secondary" : "btn-primary"}
          onClick={() => approvePayToken?.()}
        >
          Update Allowance
        </button>
      </div>
    </div>
  );
}

export default Approve;
