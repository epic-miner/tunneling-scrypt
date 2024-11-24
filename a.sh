#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error on line $1"
  exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Install Code Server
install_code_server() {
  echo "Installing Code Server..."
  curl -fsSL https://code-server.dev/install.sh | sh
  echo "Code Server installed."
}

# Run Code Server on port 6070 without authentication
run_code_server() {
  echo "Starting Code Server on port 6070 without authentication..."
  code-server --bind-addr 0.0.0.0:6070 --auth none &
  CODE_SERVER_PID=$!
  echo "Code Server started with PID $CODE_SERVER_PID"
}

# Parse tunnel arguments and execute the tunnel setup
setup_tunnel() {
  TUNNEL_CHOICE=$1
  PORT_NUMBER=$2
  NGROK_AUTH_TOKEN=""

  # Optional argument for ngrok auth token
  shift 2
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --ngrok_auth_token)
        NGROK_AUTH_TOKEN=$2
        shift
        ;;
      *)
        echo "Unknown argument: $1"
        exit 1
        ;;
    esac
    shift
  done

  # Validate the choice
  if [[ "$TUNNEL_CHOICE" != "1" && "$TUNNEL_CHOICE" != "2" && "$TUNNEL_CHOICE" != "3" && "$TUNNEL_CHOICE" != "4" ]]; then
    echo "Invalid choice. Please enter 1 for ngrok, 2 for localtunnel, 3 for Cloudflare Tunnel, or 4 for Bore Tunnel."
    exit 1
  fi

  # Validate the port number
  if ! echo "$PORT_NUMBER" | grep -qE '^[0-9]+$'; then
    echo "Invalid port number. Please enter a valid number."
    exit 1
  fi

  # Handle tunnels
  case "$TUNNEL_CHOICE" in
    1)
      if [ -z "$NGROK_AUTH_TOKEN" ]; then
        echo "ngrok auth token is required for ngrok."
        exit 1
      fi
      echo "Setting up ngrok tunnel..."
      wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
      tar -xvf ngrok-v3-stable-linux-amd64.tgz
      sudo mv ngrok /usr/local/bin/
      ngrok authtoken "$NGROK_AUTH_TOKEN"
      ngrok http "$PORT_NUMBER" &
      NGROK_PID=$!
      ;;
    2)
      echo "Setting up localtunnel..."
      if ! command -v lt >/dev/null 2>&1; then
        npm install -g localtunnel
      fi
      lt --port "$PORT_NUMBER" &
      LT_PID=$!
      ;;
    3)
      echo "Setting up Cloudflare Tunnel..."
      wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
      chmod +x cloudflared
      sudo mv cloudflared /usr/local/bin
      cloudflared tunnel --url http://localhost:"$PORT_NUMBER" &
      CF_PID=$!
      ;;
    4)
      echo "Starting Bore Tunnel using boretunnel.py..."
      python3 borecodeserver.py &
      ;;
    *)
      echo "Invalid tunnel choice."
      exit 1
      ;;
  esac
}

# Main script execution
echo "Installing and starting Code Server..."
install_code_server
run_code_server

echo "Setting up tunnel..."
setup_tunnel "$@"

# Wait for Code Server to exit
wait $CODE_SERVER_PID
