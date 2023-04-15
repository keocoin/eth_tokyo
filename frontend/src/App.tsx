import { Route, Routes } from "react-router-dom";
import { WagmiConfig, createClient, configureChains } from "wagmi";
import { infuraProvider } from "wagmi/providers/infura";
import { polygonMumbai } from "wagmi/chains";
import { InjectedConnector } from "wagmi/connectors/injected";

import { publicProvider } from "wagmi/providers/public";

import Nav from "./components/Nav";
import NewService from "./components/NewService";
import Services from "./components/Services";
import Subscription from "./components/Subscribe";
import SignMessage from "./components/Approve";

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
          <Route path="service" element={<NewService />} />
          <Route path="user" element={<Services />} />
          {/* <Route
            path="user"
            element={
              <>
                <Subscription />
                <SignMessage />
              </>
            }
          /> */}
        </Routes>
      </div>
    </WagmiConfig>
  );
}

export default App;
