import { useState } from "react";
import { usePrepareContractWrite, useContractWrite } from "wagmi";
import abi from "../../abi.json";

function CreateProvider() {
  const [providerName, setName] = useState("");

  const changeHandler = (e: any) => {
    e.preventDefault();
    setName(e.target.value);
  };

  const CreateBtn = (providerName: string) => {
    const payload = usePrepareContractWrite({
      address: `0x${process.env.CONTRACT_ADDRESS}`,
      abi: abi,
      functionName: "createProvider",
      args: [providerName],
    });

    const { data, isLoading, isSuccess, write } = useContractWrite(
      payload.config
    );
    if (write && providerName != "") {
      return (
        <>
          <button
            className="btn-primary"
            onClick={() => {
              write?.();
            }}
          >
            Submit
          </button>
          {isLoading && <div>Check Wallet</div>}
          {isSuccess && <div>Transaction: {JSON.stringify(data)}</div>}
        </>
      );
    } else {
      return (
        <>
          <button className="btn-secondary">Submit</button>
        </>
      );
    }
  };

  return (
    <div className="border-2 rounded p-4">
      <div className="text-2xl pb-4 border-b-2">Register as Provider</div>
      <div className="body py-4 space-y-4">
        <input
          type="text"
          className="border-2 p-2 w-full rounded"
          placeholder="Your provider name, ex: Netflix"
          value={providerName}
          onChange={changeHandler}
        />
        <>{CreateBtn(providerName)}</>
      </div>
    </div>
  );
}

export default CreateProvider;
