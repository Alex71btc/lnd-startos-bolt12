## Installation

LND BOLT12 is currently available only via GitHub Releases:

https://github.com/Alex71btc/lnd-startos-bolt12/releases

⚠️ This is a sideload-only package.
It is not available in the official Start9 Marketplace.

Use at your own risk.
Before testing on a production node:
- create a full backup
- understand the migration process
- never run two nodes with the same state at the same time

# BOLT12 Pay – Setup Guide

## Requirement: LND BOLT12

BOLT12 Pay requires **LND BOLT12** on StartOS.

- App name in StartOS: **LND BOLT12**
- Package ID: `lndbolt`

The default Start9 LND package does not support BOLT12 offers.

LND BOLT12 repository:
https://github.com/Alex71btc/lnd-startos-bolt12

LND BOLT12 releases:
https://github.com/Alex71btc/lnd-startos-bolt12/releases

BOLT12 Pay releases:
https://github.com/Alex71btc/bolt12-pay-start9/releases

## Installation

Both packages are currently distributed via GitHub Releases only.

⚠️ Important:
- These packages are **not available in the official Start9 Marketplace**
- Installation currently requires **manual sideloading**
- Use at your own risk

## Migrate from official Start9 LND

If you already use the official Start9 LND, you can safely migrate your node state to **LND BOLT12**.

1. Stop both services:
   - LND
   - LND BOLT12

2. Open **LND BOLT12**
3. Go to:
   - Actions
   - Import from Start9 LND

4. Wait until the import completes

Important:
- Never run both nodes with the same wallet state at the same time
- After migration, keep the old LND stopped or uninstall it

Your node identity, channels, and funds are preserved.
