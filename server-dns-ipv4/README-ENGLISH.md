# DNS Server Setup Script
This script sets up a primary DNS server using BIND 9 on Debian 12. It configures the server to be both recursive and authoritative.

## Usage
Replace placeholders in `setup-dns-server-ipv4.sh` with your actual server details:

   - `[YOUR_SERVER_IP]`
   - `[YOUR_DOMAIN]`
   - `[REVERSE_ZONE]`
   - `[FORWARDER_1_IP]`
   - `[FORWARDER_2_IP]`
   - `[SERIAL_NUMBER]`
   - `[LAST_OCTET]`

## Steps:

1. Clone the repository and navigate to the directory:

`git clone https://github.com/danielselbachtechofc/scripts-shellscript.git`

`cd scripts-shellscript`

`cd server-dns-ipv4`


3. Make the script executable:
   
`chmod +x setup-dns-server-ipv4.sh`


5. Run the script as root:
   
`sudo ./setup-dns-server-ipv4.sh`


7. Verify the DNS server is working:

`nslookup google.com 127.0.0.1`

`nslookup ns.[YOUR_DOMAIN] 127.0.0.1`

Notes
Ensure your firewall settings allow DNS traffic on port 53.
Modify the zone files and configurations as necessary to suit your environment.
