#!/bin/sh
sudo apt install nodejs npm -y

# Function to handle errors
handle_error() {
  echo "Error on line $1"
  exit 1
}

# Trap errors
trap 'handle_error $LINENO' ERR

# Prompt the user to choose between ngrok and localtunnel
echo "Choose the tunneling service you want to use:"
echo "1) ngrok"
echo "2) localtunnel"
printf "Enter your choice (1 or 2): "
read TUNNEL_CHOICE

# Validate the choice
if [ "$TUNNEL_CHOICE" != "1" ] && [ "$TUNNEL_CHOICE" != "2" ]; then
  echo "Invalid choice. Please enter 1 or 2."
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
  lt --port "$PORT_NUMBER" & wget -q -O - https://loca.lt/mytunnelpassword &
  LT_PID=$!

  # Wait for localtunnel to start
  sleep 5

  # Display localtunnel information
  echo "localtunnel started. You can access it using the localtunnel URL."

fi

# Wait for the background processes to complete
if [ "$TUNNEL_CHOICE" = "1" ]; then
  wait $NGROK_PID
elif [ "$TUNNEL_CHOICE" = "2" ]; then
  wait $LT_PID
fi
