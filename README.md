Community Reward Hub Smart Contract

The **Community Reward Hub** is a decentralized smart contract designed to manage and automate the distribution of rewards among verified community members. It ensures fair and transparent allocation of rewards based on contributions, participation, or governance metrics within a blockchain ecosystem.

---

Overview

This contract serves as the **central hub** for community reward management.  
It allows **administrators** to create and fund reward pools, while **members** can claim or receive rewards automatically according to defined parameters.

The goal is to encourage active participation, promote fairness, and enhance transparency within decentralized communities.

---

Core Features

- **Reward Pool Creation:**  
  Administrators can create and fund multiple reward pools.

- **Member Registration & Verification:**  
  Only verified users can participate and claim rewards.

- **Automated Distribution:**  
  Rewards are distributed automatically based on contribution weight or other metrics.

- **Configurable Parameters:**  
  Admins can adjust distribution rates, eligibility criteria, and reward schedules.

- **Event Logging:**  
  All key actions (registrations, claims, and updates) are recorded for on-chain transparency.

---

Contract Functions (Summary)

| Function | Description |
|-----------|-------------|
| `register-member(principal)` | Registers a new community member. |
| `verify-member(principal)` | Confirms a member’s eligibility for rewards. |
| `create-reward-pool(uint)` | Initializes a reward pool with a specified amount. |
| `distribute-rewards()` | Automatically distributes rewards to eligible members. |
| `update-reward-rate(uint)` | Allows admin to adjust reward rate or schedule. |
| `get-member-info(principal)` | Returns details of a member’s participation and rewards. |

---

Access Control

- **Admin Role:**  
  - Creates and manages reward pools.  
  - Updates distribution logic and rates.  
  - Verifies members.

- **Member Role:**  
  - Registers to participate.  
  - Receives or claims rewards transparently.

---

Smart Contract Logic

The contract ensures that:
- Rewards are distributed proportionally to contributions.  
- Unauthorized users cannot claim rewards.  
- Admin updates are recorded and auditable.  
- The reward logic remains consistent and tamper-proof.

---

Deployment

To deploy this contract on the Stacks blockchain:

```bash
clarinet contract publish community-reward-hub
