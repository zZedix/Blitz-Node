# Blitz Node - Hysteria2 Server Setup

Complete Hysteria2 node installation with panel integration, authentication, and traffic tracking.

## Installation Steps

### 1. Run Installer

Clone this repository:

```bash
git clone https://github.com/ReturnFI/Blitz-Node.git
cd Blitz-Node
```

Make the installer executable:

```bash
chmod +x install.sh
```

Run the installer:

```bash
./install.sh install <port> <sni>
```

   Example:

```bash
./install.sh install 1239 example.com
```

### 2. Configure Panel API

During installation, provide:
- **Panel URL**: `https://your-panel.com/your-path/`
- **API Key**: Your panel authentication key

The installer automatically appends:
- `/api/v1/users/` for user authentication
- `/api/v1/config/ip/nodestraffic` for traffic reporting

## Uninstall

```bash
bash install.sh uninstall
```

## Docker Deployment

The repository now includes Docker artifacts that run Hysteria2, the auth API, and the traffic collector together.

1. Use the helper script to install via Docker (mirrors `install.sh` prompts and automation):
   ```bash
   chmod +x dockerize.sh
   ./dockerize.sh install 1239 example.com
   ```
   The script will:
   - Ask for panel URL and API key, then populate `.env`.
   - Download the Blitz base `config.json`, `geoip.dat`, and `geosite.dat`.
   - Generate certificates, UUID secret, and salamander password.
   - Build images locally and launch the compose stack.
2. To stop and remove everything, run:
   ```bash
   ./dockerize.sh uninstall
   ```

The compose file exposes:
- Hysteria2 on `HYSTERIA_PORT` (UDP) for client connections.
- The auth API on `AUTH_PORT` (default `28262`).

The traffic collector runs on the configured interval and reaches Hysteria via the internal service name (`http://hysteria:25413` by default). Override additional variables in `.env` as needed (for example `SYNC_INTERVAL`, `HYSTERIA_API_BASE`, or `HYSTERIA_CONFIG_FILE`).

The single multi-stage `Dockerfile` supplies both the Python services (target `app`) and the Hysteria2 binary (target `hysteria`). Docker Compose always attempts a local build when the image tag is missing, so no extra steps are required if you are deploying fresh infrastructure. Hysteria2 can run behind the default bridge network with UDP port publishing; host networking is optional unless you need to share the server’s main IP exactly as in the original Bash installer from the Blitz panel project.[^blitz]

[^blitz]: https://github.com/ReturnFI/Blitz