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
  };

  return (
    <div className="px-4">
      <div className="update space-x-2">
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
