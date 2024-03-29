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
      <div>
        <div className="primary flex items-center justify-between p-4">
          <NavLink to="/" className="logo text-2xl">
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
      </div>
    </>
  );
}

export default Nav;
