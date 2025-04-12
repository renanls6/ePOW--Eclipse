# ePOW Mining - Script Setup OneClick 🐮⛏️

# 1. Install Script
```bash 
source <(wget -O - https://raw.githubusercontent.com/renanls6/ePOW-Eclipse/main/Epow.sh)
```

# 2. Save your wallet information:

![image](https://github.com/user-attachments/assets/098f3b53-3a28-4820-82e4-c2a3fef1b05b)

You need to have at least 0.005 ETH in your wallet. After importing it into Backpack, make sure to send the required balance

# 3. Reboot the VPS

![capture_250412_103335](https://github.com/user-attachments/assets/2f91b34e-2570-46e3-8024-f637012fec52)


# 4. Create Screen
```bash
screen -S bitz
```

![screen](https://github.com/user-attachments/assets/6b7eb7b8-f214-4df0-807a-7698e1cf9dee)


# 5. Start Bitz
```bash
cargo install bitz
```
![install](https://github.com/user-attachments/assets/62c92383-106e-4b75-b13c-3b50d4c7c487)


# 6. Using Bitz

Start eMining
```bash
bitz collect
```

![node on](https://github.com/user-attachments/assets/346c2c5a-97d9-487b-b9b5-936195c97967)


Other Commands:

• Claim your Bitz: bitz claim

• Check your balance: bitz account

• Config CPU (change the number to change cores): bitz collect --cores 8

• View all commands: bitz -h

