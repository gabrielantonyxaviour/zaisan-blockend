import { ChainMap, ChainMetadata } from '@hyperlane-xyz/sdk';

// A map of chain names to ChainMetadata
export const chains: ChainMap<ChainMetadata> = {
  // ----------- Add your chains here -----------------
  mantleTestnet: {
    name: 'mantleTestnet',
    chainId: 5001,
    publicRpcUrls: [
      {
        http: 'https://rpc.testnet.mantle.xyz',
      },
    ],
  },
  polygonzkevmTestnet: {
    name: 'polygonzkevmTestnet',
    chainId: 1442,
    publicRpcUrls: [
      {
        http: 'https://rpc.public.zkevm-test.net',
      },
    ],
  },
  scrollTestnet: {
    name: 'scrollTestnet',
    chainId: 534353,
    publicRpcUrls: [
      {
        http: 'https://alpha-rpc.scroll.io/l2',
      },
    ],
  },
  taikoDevnet: {
    name: 'taikoDevnet',
    chainId: 167002,
    publicRpcUrls: [
      {
        http: 'https://l2rpc.hackathon.taiko.xyz',
        webSocket: 'https://l2ws.hackathon.taiko.xyz/',
      },
    ],
    transactionOverrides: {
      gasLimit: 500000,
    },
  },
  chiadoTestnet: {
    name: 'chiadoTestnet',
    chainId: 10200,
    publicRpcUrls: [
      {
        http: 'https://rpc.chiadochain.net',
      },
    ],
  },
};
