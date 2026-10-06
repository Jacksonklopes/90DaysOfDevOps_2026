# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

## 🎯 Objective

Today, I learned the basic networking concepts used to connect systems and services. I focused on how DNS resolves domain names, how IP addresses identify devices, how CIDR and subnets organize networks, and how ports direct traffic to specific services.

---

## Task 1: DNS – How Names Become IPs

### 1. What happens when you type `google.com` in a browser?

When I type `google.com`, my system needs to find the IP address connected to that domain name. DNS looks up the domain and returns an IP address. My browser then uses that IP address to connect to Google's server and load the website.

### 2. DNS Record Types

- `A` → Maps a domain name to an IPv4 address.
- `AAAA` → Maps a domain name to an IPv6 address.
- `CNAME` → Creates an alias that points one domain name to another domain name.
- `MX` → Specifies the mail server used to receive emails for a domain.
- `NS` → Specifies the authoritative name servers for a domain.

### 3. Checking DNS Records

**dig** – queries DNS servers and returns detailed record information
```bash
dig google.com
```

**nslookup** – simpler tool to look up a specific DNS record type
```bash
nslookup -type=MX google.com
```

From the `dig google.com` output:

- A Record → `YOUR-A-RECORD`
- TTL → `YOUR-TTL` (time to live)

---

## Task 2: IP Addressing

### 1. What is an IPv4 address?

An IPv4 address is a unique address used to identify a device on a network. It is made up of **32 bits**, divided into four parts called octets. Each octet can have a value from `0` to `255`.

Example:
```text
192.168.1.10
```

### 2. Public vs Private IP Address

- **Public IP** → An IP address used to communicate over the internet.
```text
  8.8.8.8
```
- **Private IP** → An IP address used inside a private network, such as a home, office, or cloud network.
```text
  192.168.1.10
```

### 3. Private IP Ranges

```text
10.0.0.0 – 10.255.255.255
172.16.0.0 – 172.31.255.255
192.168.0.0 – 192.168.255.255
```

### 4. Checking IP Addresses

```bash
ip addr show
```

This command displays the network interfaces and their assigned IP addresses.

From the output, my private IP address:
```text
YOUR-PRIVATE-IP
```

---

## Task 3: CIDR & Subnetting

### 1. What is CIDR?

**CIDR** stands for **Classless Inter-Domain Routing** — a way to write an IP network using `/number` notation.

```text
192.168.1.0/24 (192.168.1.0 - 32 bits)
```

### 2. What does `/24` mean?

- **24 bits** → Network
- **8 bits** → Hosts
- so ip adress has total of 32 bits)

Subnet mask:
```text
255.255.255.0
```

### 3. Usable Hosts

```text
Total IPs = 2^(32 - CIDR(24 or 16))
Usable Hosts = Total IPs - 2
```

The 2 reserved IPs are:
- **Network address** → Represents the network.
- **Broadcast address** → Used to communicate with all devices in the network.

| CIDR  | Subnet Mask       | Total IPs | Usable Hosts |
|-------|-------------------|-----------|--------------|
| `/24` | `255.255.255.0`   | `256`     | `254`        |
| `/16` | `255.255.0.0`     | `65,536`  | `65,534`     |
| `/28` | `255.255.255.240` | `16`      | `14`         |

### 4. Why do we subnet?

**Subnetting** means dividing one large network into smaller networks. It helps to:
- Organize devices
- Use IP addresses efficiently
- Separate different networks

---

## Task 4: Ports – The Doors to Services

### 1. What is a Port?

A **port** is a number used to identify a specific service running on a device.

```text
IP Address → Identifies the device
Port       → Identifies the service
```

We need ports so multiple services can run on the same device.

### 2. Common Ports

| Port    | Service |
|---------|---------|
| `22`    | SSH     |
| `80`    | HTTP    |
| `443`   | HTTPS   |
| `53`    | DNS     |
| `3306`  | MySQL   |
| `6379`  | Redis   |
| `27017` | MongoDB |

### 3. Check Listening Ports

```bash
ss -tulpn
```

The `ss` command shows network connections and listening ports.

**Listening ports found:**
```text
Port → Service
22   → SSH
80   → HTTP
```

> Replace the ports above with 2 ports from your actual command output. Add your screenshot here.

---

## Task 5: Putting It Together

**1. You run `curl http://myapp.com:8080` — what networking concepts from today are involved?**

DNS resolution happens first (`myapp.com` → IP address, e.g. via `dig` or `nslookup`). Then a TCP connection is made to that IP on port `8080`. Finally, an HTTP request is sent and a response is returned — this is what `curl` displays.

**2. Your app can't reach a database at `10.0.1.50:3306` — what would you check first?**

First, check if the IP is reachable (`ping 10.0.1.50` or check network/routing). Then check if port `3306` is open and listening using `ss -tulpn` on the DB server, or try connecting with `curl` / `telnet 10.0.1.50 3306`. Also check firewall rules and whether the database service is running.

---

## Documentation

### What I Learned

- DNS converts domain names into IP addresses.
- IPv4 is used to identify devices on a network.
- CIDR defines the size of an IP network.
- Subnetting divides a network into smaller networks.
- Ports identify specific services running on a device.
- Different services use different ports, such as SSH `22`, HTTP `80`, and HTTPS `443`.

### Commands Used

```bash
dig google.com
nslookup -type=MX google.com
ip addr show
ss -tulpn
curl -I https://google.com
```

### Key Points

1. **DNS** → Domain name → IP address
2. **IP Address** → Identifies a device
3. **Port** → Identifies a service
