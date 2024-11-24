import subprocess
import os

def install_rust():
    try:
        # Step 1: Install Rust
        print("Installing Rust...")
        subprocess.run("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y", shell=True, check=True)
        
        # Step 2: Source Rust environment
        print("Sourcing Rust environment...")
        source_cmd = "source $HOME/.cargo/env"
        os.system(source_cmd)
        
        # Step 3: Install bore-cli
        print("Installing bore-cli with Cargo...")
        subprocess.run("$HOME/.cargo/bin/cargo install bore-cli", shell=True, check=True)
        
        print("Rust and bore-cli installed successfully.")
        
    except subprocess.CalledProcessError as e:
        print(f"An error occurred during installation: {e}")

def start_bore():
    try:
        # Prompt the user for the port number
        port = 6070
        
        # Run bore command with the specified port
        print(f"Starting bore on local port {port}...")
        subprocess.run(f"$HOME/.cargo/bin/bore local {port} --to bore.pub", shell=True, check=True)
        
    except subprocess.CalledProcessError as e:
        print(f"Failed to start bore: {e}")

if __name__ == "__main__":
    install_rust()
    start_bore()
