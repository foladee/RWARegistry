# RWARegistry

A Clarity smart contract for managing and tracking tokenized real-world assets (RWA) on the Stacks blockchain.

## Overview

RWARegistry is a production-ready smart contract that enables the registration, management, and lifecycle tracking of real-world assets tokenized on Stacks. It provides a secure, immutable registry with owner-based access control and comprehensive asset metadata management.

## Features

- **Asset Registration**: Register new real-world assets with IPFS metadata hash and valuation
- **Ownership Transfer**: Securely transfer asset ownership between principals
- **Valuation Management**: Update asset valuations with owner authorization
- **Asset Lifecycle**: Deactivate assets while preserving complete historical records
- **Owner-Based Access Control**: Only asset owners can modify their assets
- **Comprehensive Validation**: Built-in validation for IDs, valuations, and metadata
- **Immutable History**: All asset changes are permanently recorded on-chain

## How It Works

1. **Register Asset**: Owner registers a new asset with metadata hash and initial valuation
2. **Track Ownership**: Asset ownership can be transferred to new principals
3. **Update Valuation**: Owner can update asset valuation at any time
4. **Deactivate**: Owner can deactivate assets while keeping full audit trail
5. **Query**: Anyone can retrieve asset details by ID

## Contract Functions

### Public Functions

#### `register-asset(metadata-hash, valuation)`
Register a new real-world asset.

**Parameters:**
- `metadata-hash` (buff 64): IPFS hash containing asset metadata
- `valuation` (uint): Initial asset valuation in microSTX

**Returns:** Asset ID (uint)

**Example:**
```clarity
(contract-call? .rwa-registry register-asset 
  0x1234567890abcdef... 
  u1000000000)
