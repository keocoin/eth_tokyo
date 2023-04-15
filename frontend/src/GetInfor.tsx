import * as React from "react";
import {
  usePrepareContractWrite,
  useContractWrite,
  useContractRead,
} from "wagmi";
import abi from "../abi.json";

function GetInfor() {
  const result = useContractRead({
    address: `0x${process.env.CONTRACT_ADDRESS}`,
    abi: abi,
    functionName: "getProvider",
    args: [1],
  });

  console.log(result.data);

  const result2 = useContractRead({
    address: `0x${process.env.CONTRACT_ADDRESS}`,
    abi: abi,
    functionName: "getService",
    args: [1],
  });

  console.log(result2.data);

  React.useEffect(() => {}, []);

  return <div></div>;
}

export default GetInfor;
