import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import { WagmiConfig, createClient, configureChains } from "wagmi";
import { infuraProvider } from "wagmi/providers/infura";
import { polygonMumbai, mainnet } from "wagmi/chains";
import { InjectedConnector } from "wagmi/connectors/injected";

import { publicProvider } from "wagmi/providers/public";

import Nav from "./components/Nav";
import Provider from "./components/Provider";
import Service from "./components/Service";
import Subscription from "./components/Sub";
import SignMessage from "./components/Approve";
import GetInfor from "./GetInfor";
import Renew from "./Renew";

const { chains, provider } = configureChains(
  [polygonMumbai],
  [infuraProvider({ apiKey: `${process.env.INFURA_KEY}` }), publicProvider()]
);

const client = createClient({
  autoConnect: true,
  connectors: [new InjectedConnector({ chains })],
  provider,
});

function App() {
  return (
    <WagmiConfig client={client}>
      <Nav />
      <div className="max-w-screen-sm mx-auto py-8">
        <Routes>
          <Route path="provider" element={<Provider />} />
          <Route path="service" element={<Service />} />
          <Route
            path="user"
            element={
              <>
                <Subscription />
                <SignMessage />
              </>
            }
          />
        </Routes>

        {/* <GetInfor />
        <Renew /> */}
      </div>
    </WagmiConfig>
  );
}

export default App;
