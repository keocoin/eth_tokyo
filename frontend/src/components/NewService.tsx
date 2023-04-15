import { useState } from "react";
import { usePrepareContractWrite, useContractWrite } from "wagmi";
import abi from "../../abi.json";

function NewService() {
  const [serviceName, setName] = useState("");
  const [unitPrice, setPrice] = useState("1");
  const [duration, setDuration] = useState("1");

  const CreateBtn = () => {
    const payload = usePrepareContractWrite({
      address: `0x${process.env.CONTRACT_ADDRESS}`,
      abi: abi,
      functionName: "createService",
      args: [serviceName, unitPrice, duration],
    });

    const { data, isLoading, isSuccess, write } = useContractWrite(
      payload.config
    );
    if (!write || serviceName == "" || unitPrice == "" || duration == "") {
      return (
        <>
          <button className="btn-secondary">Submit</button>
        </>
      );
    } else {
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
    }
  };

  return (
    <div className="p-4">
      <div className="border-2 rounded p-4">
        <div className="text-2xl pb-4 border-b-2">Add new Service</div>
        <div className="body py-4 space-y-4">
          <div className="group space-y-2">
            <div className="label">Service name</div>
            <input
              type="text"
              className="border-2 p-2 w-full rounded"
              placeholder="Netflix"
              value={serviceName}
              onChange={(e) => {
                setName(e.target.value);
              }}
            />
          </div>

          <div className="group space-y-2">
            <div className="label">Unit Price</div>
            <input
              type="text"
              className="border-2 p-2 w-full rounded"
              placeholder="1"
              value={unitPrice}
              onChange={(e) => {
                setPrice(e.target.value);
              }}
            />
          </div>

          <div className="group space-y-2">
            <div className="label">Duration</div>
            <input
              type="text"
              className="border-2 p-2 w-full rounded"
              placeholder="1"
              value={duration}
              onChange={(e) => {
                setDuration(e.target.value);
              }}
            />
          </div>
          <>{CreateBtn()}</>
        </div>
      </div>
    </div>
  );
}

export default NewService;
