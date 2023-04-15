import { useAccount, useConnect, useDisconnect } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import {
  WalletIcon,
  ArrowRightOnRectangleIcon,
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
      <div className="border-b flex items-center justify-between p-4 bg-gray-900 text-white">
        <div className="logo text-2xl">Subn.Xyz</div>
        <div className="menu items-center justify-around space-x-8">
          <NavLink to="/provider" className="hover:underline">
            as Provider
          </NavLink>
          <NavLink to="/user" className="hover:underline">
            as User
          </NavLink>
        </div>
        <div>
          <div className="flex items-center space-x-2 btn-primary bg-orange-600 hover:bg-orange-900 hover:cursor-pointer">
            <WalletIcon className="h-6 w-6" />
            {isConnected && (
              <>
                {`${address?.slice(0, 5)}...${address?.slice(-5)}`}
                <button onClick={() => disconnect()}>
                  <ArrowRightOnRectangleIcon className="h-6 w-6" />
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
      </div>
    </>
  );
}

export default Nav;
