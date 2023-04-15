import { useAccount, useConnect, useDisconnect } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import {
  WalletIcon,
  ArrowRightOnRectangleIcon,
  PlusIcon,
  SquaresPlusIcon,
} from "@heroicons/react/24/solid";
import { NavLink } from "react-router-dom";

function Nav() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect({
    connector: new InjectedConnector(),
  });
  const { disconnect } = useDisconnect();

  return (
    <>
      <div>
        <div className="primary flex items-center justify-between p-4">
          <NavLink to="/provider" className="logo text-2xl">
            Subn.Xyz
          </NavLink>
          <div className="flex items-center space-x-2 btn-primary bg-orange-600 hover:bg-orange-900 hover:cursor-pointer">
            <WalletIcon className="icon" />
            {isConnected && (
              <>
                {`${address?.slice(0, 5)}...${address?.slice(-5)}`}
                <button onClick={() => disconnect()}>
                  <ArrowRightOnRectangleIcon className="icon" />
                </button>{" "}
              </>
            )}
            {!isConnected && (
              <>
                <button onClick={() => connect()}>Connect Wallet</button>
              </>
            )}
          </div>
        </div>
        <div className="bg-gray-200">
          <div className="">
            <div className="secondary menu items-center flex">
              <NavLink
                to="/service"
                className={({ isActive, isPending }) =>
                  `p-4 space-x-2 px-4 flex w-full h-full font-semibold ${
                    isActive ? "bg-blue-700 text-white" : "bg-gray-200"
                  }`
                }
              >
                <PlusIcon className="icon" /> <span>Service</span>
              </NavLink>
              <NavLink
                to="/user"
                className={({ isActive, isPending }) =>
                  `p-4 space-x-2 px-4 flex w-full font-semibold ${
                    isActive ? "bg-blue-700 text-white" : "bg-gray-200"
                  }`
                }
              >
                <SquaresPlusIcon className="icon" />
                <span>Subscriptions</span>
              </NavLink>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}

export default Nav;
