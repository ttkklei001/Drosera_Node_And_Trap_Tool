#!/bin/bash

# K2 节点教程分享 | https://x.com/BtcK241918 | Telegram: https://t.me/+EaCiFDOghoM3Yzll
# K2 Node Tutorial Share | https://x.com/BtcK241918 | Telegram: https://t.me/+EaCiFDOghoM3Yzll

function pause() {
  read -n1 -r -p "Press any key to return to the main menu..." key
  echo
}

# ========== Trap 合约功能 / Trap Contract Features ==========
function trap_main_menu() {
  echo "=============== Trap 合约部署菜单 / Trap Contract Deployment Menu ==============="
  echo "1) 部署 Trap 合约 / Deploy Trap Contract"
  echo "2) 设置 Trap 白名单 / Set Trap Whitelist"
  echo "3) 返回主菜单 / Return to Main Menu"
  echo "================================================="
  read -p "选择操作 / Choose an option (1-3): " choice

  case $choice in
    1) init_and_deploy_trap ;;
    2) setup_whitelist ;;
    3) main_menu ;;
    *) echo "无效选项 / Invalid option"; trap_main_menu ;;
  esac
}

function init_and_deploy_trap() {
  rm -rf my-drosera-trap
  forge init my-drosera-trap -t https://github.com/drosera-network/trap-foundry-template
  cd my-drosera-trap || exit

  read -p "GitHub 邮箱 / GitHub Email: " GITHUB_EMAIL
  read -p "GitHub 用户名 / GitHub Username: " GITHUB_USERNAME
  git config --global user.email "$GITHUB_EMAIL"
  git config --global user.name "$GITHUB_USERNAME"

  rm -rf node_modules bun.lockb
  bun install
  forge build

  read -p "请输入 EVM 私钥 / Enter EVM Private Key: " DEPLOY_KEY
  DEPLOY_KEY=${DEPLOY_KEY#0x}
  export DEPLOY_KEY_GLOBAL=$DEPLOY_KEY

  echo "ofc" | DROSERA_PRIVATE_KEY=$DEPLOY_KEY drosera apply

  pause
  trap_main_menu
}

function setup_whitelist() {
  read -p "EVM 钱包地址 / EVM Wallet Address: " public_address
  cd ~/my-drosera-trap || exit
  sed -i "/\[traps\.mytrap\]/,/^\[/ s/whitelist = \[.*\]/whitelist = [\"$public_address\"]/" drosera.toml

  read -p "用于配置的私钥 / Private Key for Configuration: " update_priv_key
  DROSERA_PRIVATE_KEY="$update_priv_key" drosera apply

  pause
  trap_main_menu
}

# ========== Operator 节点功能 / Operator Node Features ==========
function install_operator() {
  echo "安装 Drosera Operator v1.16.2 / Installing Drosera Operator v1.16.2..."
  cd /usr/local/bin
  curl -LO https://github.com/drosera-network/releases/releases/download/v1.16.2/drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
  tar -xvf drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
  rm -f drosera-operator-v1.16.2-x86_64-unknown-linux-gnu.tar.gz
  chmod +x drosera-operator
  echo "Drosera Operator v1.16.2 安装完成 / Drosera Operator v1.16.2 installation completed."
  pause
}

function register_operator() {
  read -p "请输入你的 RPC 地址 / Enter your RPC Address: " eth_rpc
  read -p "请输入你的 EVM 私钥 / Enter your EVM Private Key: " private_key
  drosera-operator register --eth-rpc-url "$eth_rpc" --eth-private-key "$private_key"
  pause
}

function start_service() {
  read -p "请输入你的 RPC 地址 / Enter your RPC Address: " eth_rpc
  read -p "请输入你的 EVM 私钥 / Enter your EVM Private Key: " private_key
  read -p "请输入你的 Drosera 地址 / Enter your Drosera Address: " drosera_address
  read -p "请输入你的 VPS 公网 IP 地址 / Enter your VPS Public IP: " vps_ip

  cat <<EOF > /etc/systemd/system/drosera.service
[Unit]
Description=Drosera Node Service
After=network-online.target

[Service]
User=root
Restart=always
RestartSec=15
LimitNOFILE=65535
ExecStart=/usr/local/bin/drosera-operator node --db-file-path /root/.drosera.db --network-p2p-port 31313 --server-port 31314 \\
  --eth-rpc-url $eth_rpc \\
  --eth-backup-rpc-url https://1rpc.io/holesky \\
  --drosera-address $drosera_address \\
  --eth-private-key $private_key \\
  --listen-address $vps_ip \\
  --network-external-p2p-address $vps_ip \\
  --disable-dnr-confirmation true

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable drosera
  systemctl start drosera
  echo "Drosera 节点已启动并设置为开机自启 / Drosera node has started and set to auto-start on boot."
  pause
}

function view_logs() {
  echo "查看 Drosera 节点日志 / Viewing Drosera Node Logs..."
  journalctl -u drosera.service -f --no-pager
}

function uninstall() {
  echo "正在卸载 Drosera 节点 / Uninstalling Drosera Node..."
  systemctl stop drosera
  systemctl disable drosera
  rm -f /etc/systemd/system/drosera.service
  rm -f /usr/local/bin/drosera-operator
  rm -f /root/.drosera.db
  systemctl daemon-reload
  echo "Drosera 节点已卸载完成 / Drosera node has been uninstalled."
  pause
}

# ========== 主菜单 / Main Menu ==========
function main_menu() {
  while true; do
    clear
    echo "=============== K2 节点教程分享 / K2 Node Tutorial Share ==============="
    echo "推特: https://x.com/BtcK241918 | Telegram: https://t.me/+EaCiFDOghoM3Yzll"
    echo "=============== K2 Drosera 一键部署助手 / K2 Drosera One-Click Deployment Assistant ==============="
    echo "1. 进入 Trap 合约菜单 / Go to Trap Contract Menu"
    echo "2. 安装 Drosera Operator v1.16.2 / Install Drosera Operator v1.16.2"
    echo "3. 注册运营商 / Register Operator"
    echo "4. 启动 Drosera 节点 / Start Drosera Node"
    echo "5. 查看日志 / View Logs"
    echo "6. 卸载 Drosera 节点 / Uninstall Drosera Node"
    echo "7. 退出 / Exit"
    echo "========================================================"
    read -p "请输入你的选择 / Enter your choice: " choice
    case $choice in
      1) trap_main_menu ;;
      2) install_operator ;;
      3) register_operator ;;
      4) start_service ;;
      5) view_logs ;;
      6) uninstall ;;
      7) exit 0 ;;
      *) echo "无效的选项 / Invalid option，请重新输入 / please try again." ; sleep 1 ;;
    esac
  done
}

# 启动主菜单 / Start main menu
main_menu
