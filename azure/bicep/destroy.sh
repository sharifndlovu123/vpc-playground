#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${1:-${RESOURCE_GROUP:?Set RESOURCE_GROUP env var or pass as first arg}}"

VNET_NAME="${VNET_NAME:-sample_vnet}"
PRIVATE_NSG_NAME="${PRIVATE_NSG_NAME:-sample-private-nsg}"
PUBLIC_NSG_NAME="${PUBLIC_NSG_NAME:-sample-public-nsg}"
NETWORK_MANAGER_NAME="${NETWORK_MANAGER_NAME:-sample_vnet-network-manager}"
IPAM_POOL_NAME="${IPAM_POOL_NAME:-sample_vnet-ipv4-pool}"

# delete in reverse dependency order: vnet (and its subnets) first,
# then the NSGs and IPAM pool it referenced, then the network manager.
az network vnet delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME"

az network nsg delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PRIVATE_NSG_NAME"

az network nsg delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$PUBLIC_NSG_NAME"

az network manager ipam-pool delete \
  --resource-group "$RESOURCE_GROUP" \
  --network-manager-name "$NETWORK_MANAGER_NAME" \
  --name "$IPAM_POOL_NAME" \
  --yes

az network manager delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$NETWORK_MANAGER_NAME" \
  --yes
