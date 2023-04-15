import {
  usePrepareContractWrite,
  useContractWrite,
  useContractRead,
} from "wagmi";
import abi from "../../abi.json";
import Approve from "./Approve";

function Subscribe(serviceId: Number) {
  const { config } = usePrepareContractWrite({
    address: `0x${process.env.CONTRACT_ADDRESS}`,
    abi: abi,
    functionName: "subscribe",
    args: [serviceId, process.env.AUTO_RENEW_DEFAULT],
  });

  const { write } = useContractWrite(config);

  return (
    <div>
      <button
        className={!write ? "btn-secondary" : "btn-primary"}
        disabled={!write}
        onClick={() => write?.()}
      >
        Subscribe
      </button>
    </div>
  );
}

const Services = () => {
  const result = useContractRead({
    address: `0x${process.env.CONTRACT_ADDRESS}`,
    abi: abi,
    functionName: "getAllServices",
  });

  let servives = [];

  if (result.isSuccess) {
    servives = result.data.map((v: any, i: any) => {
      return {
        name: v.name,
        durationTime: parseInt(v.durationTime._hex),
        unitPrice: parseInt(v.unitPrice._hex),
        provider: v.provider,
        id: parseInt(v.id._hex),
      };
    });
  }

  return (
    <>
      <div className="p-4 space-y-2">
        {servives.map((v: any, i: number) => {
          return (
            <div key={i} className="p-4 border rounded-lg">
              <div className="text-2xl">{v.name}</div>
              <div className="flex items-center">
                <div className="w-full">
                  <div className="provider">
                    Provider:{" "}
                    {`${v.provider?.slice(0, 8)}...${v.provider?.slice(-8)}`}
                  </div>
                  <div className="unit_price">Unit Price: {v.unitPrice}</div>
                  <div className="unit_duration">
                    Duration time: {v.durationTime}
                  </div>
                </div>
                {Subscribe(v.id)}
              </div>
            </div>
          );
        })}
      </div>
      <Approve />
    </>
  );
};

export default Services;
