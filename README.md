# ePOW Mining - Script Setup OneClick

# 1. Install Script
```bash 
source <(wget -O - https://raw.githubusercontent.com/renanls6/ePOW-Eclipse/main/Epow.sh)
```

# 2. Save your wallet information:

![image](https://github.com/user-attachments/assets/098f3b53-3a28-4820-82e4-c2a3fef1b05b)


# 3. Reboot the VPS

![capture_250412_103335](https://github.com/user-attachments/assets/2f91b34e-2570-46e3-8024-f637012fec52)


4. Create a Wallet (Keypair)
```bash
solana-keygen new
```
Set Passphrase for better security or just skip (click enter)

This will create a new keypair at the default path: ```~/.config/solana/id.json```

Save your public key & mnemonic — it will be shown after creation.
<br><br>
<br><br>
5. Install Bitz CLI
```bash
cargo install bitz
```
6. Change RPC
```bash
solana config set --url https://mainnetbeta-rpc.eclipse.xyz/
```
  or
```bash
solana config set --url https://eclipse.helius-rpc.com/
```
7. Open Screen
```bash
screen -S eclipse
```
8. Start eMining
```bash
bitz collect
```
