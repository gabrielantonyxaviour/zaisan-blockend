import { ChainMap, MultisigIsmConfig } from '@hyperlane-xyz/sdk';

export const multisigIsmConfig: ChainMap<MultisigIsmConfig> = {
  // ----------- Your chains here -----------------
  mantleTestnet: {
    threshold: 1,
    validators: ['0x904F1AfcEbb2175671A1a68d05813811A59d5a93'],
  },
  polygonzkevmTestnet: {
    threshold: 1,
    validators: ['0x904F1AfcEbb2175671A1a68d05813811A59d5a93'],
  },
  chiadoTestnet: {
    threshold: 1,
    validators: ['0x904F1AfcEbb2175671A1a68d05813811A59d5a93'],
  },
  taikoDevnet: {
    threshold: 1,
    validators: ['0x904F1AfcEbb2175671A1a68d05813811A59d5a93'],
  },
  scrollTestnet: {
    threshold: 1,
    validators: ['0x904F1AfcEbb2175671A1a68d05813811A59d5a93'],
  },
};
