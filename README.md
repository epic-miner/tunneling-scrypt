
## Usage

Run the script with the following syntax:

```bash
bash tunnel.sh <tunnel_choice> <port_number> [--ngrok_auth_token <token>]
```

### Parameters

- `<tunnel_choice>`: Choose the tunneling service:
  - `1` for ngrok
  - `2` for localtunnel
  - `3` for Cloudflare Tunnel

- `<port_number>`: The local port number you want to forward.

- `[--ngrok_auth_token <token>]`: Optional, required only for `ngrok`. Your ngrok authentication token.

### Examples

1. **Using ngrok**

   ```bash
   bash tunnel.sh 1 8888 --ngrok_auth_token YOUR_NGROK_AUTH_TOKEN
   ```

   This command sets up an ngrok tunnel on port `8888` using the provided auth token.

2. **Using localtunnel**

   ```bash
   bash tunnel.sh 2 8888
   ```

   This command sets up a localtunnel on port `8888`.

3. **Using Cloudflare Tunnel**

   ```bash
   bash tunnel.sh 3 8888
   ```

   This command sets up a Cloudflare Tunnel on port `8888`.

## Troubleshooting

- **Script Not Executing**: Ensure you have made the script executable with `chmod +x tunnel.sh`.
- **Command Not Found**: Make sure `ngrok`, `localtunnel`, and `cloudflared` are installed and available in your PATH.
- **Permission Issues**: The script may require `sudo` privileges to install certain tools.

## License

This script is provided as-is. Use it at your own risk. No warranties are provided.

## Contact

For issues or contributions, please contact [your_email@example.com](mailto:your_email@example.com).

```

### Explanation

- **Prerequisites**: Lists dependencies required to run the script.
- **Installation**: Provides steps to download and prepare the script.
- **Usage**: Details the command syntax and parameters.
- **Examples**: Shows how to use the script with different tunneling services.
- **Troubleshooting**: Offers help for common issues.
- **License**: States that the script is provided without warranty.
- **Contact**: Provides contact information for support.
