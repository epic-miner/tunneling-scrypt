#!/bin/sh
sudo apt install nodejs npm -y

# Function to handle errors
handle_error() {
  echo "Error on line $1"
  exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Prompt the user to choose between ngrok, localtunnel, and Cloudflare
echo "Choose the tunneling service you want to use:"
echo "1) ngrok"
echo "2) localtunnel"
echo "3) Cloudflare Tunnel"
printf "Enter your choice (1, 2, or 3): "
read TUNNEL_CHOICE

# Validate the choice
if [ "$TUNNEL_CHOICE" != "1" ] && [ "$TUNNEL_CHOICE" != "2" ] && [ "$TUNNEL_CHOICE" != "3" ]; then
  echo "Invalid choice. Please enter 1, 2, or 3."
  exit 1
fi

# Prompt the user for the port number to forward
printf "Enter the port number to forward: "
read PORT_NUMBER

# If ngrok is chosen
if [ "$TUNNEL_CHOICE" = "1" ]; then
  # Prompt for ngrok auth token
  printf "Enter your ngrok auth token: "
  read NGROK_AUTH_TOKEN

  # Download and install ngrok
  wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
  tar -xvf ngrok-v3-stable-linux-amd64.tgz
  sudo mv ngrok /usr/local/bin/

  # Authenticate ngrok
  ngrok authtoken "$NGROK_AUTH_TOKEN"

  # Start ngrok
  ngrok http "$PORT_NUMBER" &
  NGROK_PID=$!

  # Wait for ngrok to start
  sleep 5

  # Display ngrok tunnel URL
  echo "ngrok tunnel started. You can access it at the URL provided by ngrok."

# If localtunnel is chosen
elif [ "$TUNNEL_CHOICE" = "2" ]; then
  # Install localtunnel
  npm install -g localtunnel

  # Start localtunnel
  lt --port "$PORT_NUMBER" &
  LT_PID=$!

  # Wait for localtunnel to start
  sleep 5

  # Display localtunnel information
  echo "localtunnel started. You can access it using the localtunnel URL."

# If Cloudflare Tunnel is chosen
elif [ "$TUNNEL_CHOICE" = "3" ]; then
  # Download and install cloudflared
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O cloudflared
  chmod +x cloudflared
  sudo mv cloudflared /usr/local/bin

  # Start Cloudflare Tunnel without credentials
  cloudflared tunnel --url http://localhost:"$PORT_NUMBER" &
  CF_PID=$!

  # Wait for Cloudflare Tunnel to start
  sleep 5

  # Display Cloudflare Tunnel information
  echo "Cloudflare Tunnel started. You can access it using the Cloudflare Tunnel URL."

fi

# Wait for the background processes to complete
if [ "$TUNNEL_CHOICE" = "1" ]; then
  wait $NGROK_PID
elif [ "$TUNNEL_CHOICE" = "2" ]; then
  wait $LT_PID
elif [ "$TUNNEL_CHOICE" = "3" ]; then
  wait $CF_PID
fi
