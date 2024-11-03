#!/bin/bash

# Function to handle errors
handle_error() {
  echo "Error on line $1"
  exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Prompt for tunnel choice if not provided
if [ -z "$1" ]; then
  echo "Choose a tunneling option:"
  echo "1 - ngrok"
  echo "2 - localtunnel"
  echo "3 - Cloudflare Tunnel"
  echo "4 - Bore Tunnel"
  read -rp "Enter your choice (1/2/3/4): " TUNNEL_CHOICE
else
  TUNNEL_CHOICE=$1
fi

# Prompt for port if not provided
if [ -z "$2" ]; then
  read -rp "Enter the port number you want to expose: " PORT_NUMBER
else
  PORT_NUMBER=$2
fi

# Optional argument for ngrok auth token
NGROK_AUTH_TOKEN=""
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

# Handle ngrok
if [ "$TUNNEL_CHOICE" = "1" ]; then
  if [ -z "$NGROK_AUTH_TOKEN" ]; then
    echo "ngrok auth token is required for ngrok."
    exit 1
  fi

  # Download and install ngrok if necessary
  if ! command -v ngrok &> /dev/null; then
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    tar -xvf ngrok-v3-stable-linux-amd64.tgz
    sudo mv ngrok /usr/local/bin/
  fi

  # Authenticate ngrok
  ngrok authtoken "$NGROK_AUTH_TOKEN"

  # Start ngrok
  ngrok http "$PORT_NUMBER" &
  NGROK_PID=$!

  # Display ngrok tunnel URL
  echo "ngrok tunnel started. Access URL will appear in ngrok's web interface."

  # Wait for the ngrok process to complete
  wait $NGROK_PID

# Handle localtunnel
elif [ "$TUNNEL_CHOICE" = "2" ]; then
  # Install localtunnel if not already installed
  if ! command -v lt >/dev/null 2>&1; then
    echo "Installing localtunnel..."
    npm install -g localtunnel
  fi

  # Start localtunnel
  lt --port "$PORT_NUMBER" &
  LT_PID=$!

  # Display localtunnel information
  echo "localtunnel started. Check the terminal for the generated URL."

  # Wait for the localtunnel process to complete
  wait $LT_PID

# Handle Cloudflare Tunnel
elif [ "$TUNNEL_CHOICE" = "3" ]; then
  # Download and install cloudflared if necessary
  if [ ! -f /usr/local/bin/cloudflared ]; then
    echo "Installing cloudflared..."
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin
  fi

  # Start Cloudflare Tunnel
  cloudflared tunnel --url http://localhost:"$PORT_NUMBER" &
  CF_PID=$!

  # Display Cloudflare Tunnel information
  echo "Cloudflare Tunnel started. Use the Cloudflare dashboard for URL information."

  # Wait for the Cloudflare Tunnel process to complete
  wait $CF_PID

# Handle Bore Tunnel
elif [ "$TUNNEL_CHOICE" = "4" ]; then
  # Execute the Python script for Bore Tunnel
  echo "Starting Bore Tunnel using boretunnel.py..."
  python3 boretunnel.py
fi
