# cloudflared-initramfs

Use dropbear over cloudflared.

Enables cloudflared tunnel during kernel boot, before encrypted partitions
are mounted. Combined with [dropbear](https://github.com/mkj/dropbear) this
can enable FULLY ENCRYPTED remote booting without storing key material or
exposing ports on the remote network. An Internet connection simply needs to
exist that can reach the cloudflared server endpoint.

Normal dropbear connections and DNS resolution can be used to find cloudflared
endpoints.
This essentially enables the creation of a fully encrypted remote-managed 
node, with the ability to prevent all local access.

## Requirements

Working knowledge of Linux. Understanding of networking and cloudflared.

1. [Debian Bullseye/Bookworm](https://debian.org) (any version with cloudflared
   support should work, but untested).
2. [cloudflared](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) installed, configured and in a
   "known working" state.

## Getting started

Installation is supported via make.
Download, extract and configure contents, and install on target machine.

### Installation
[Token](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/configure-tunnels/remote-management/#view-the-tunnel-token)
```bash
TOKEN=<cloudflare token> make install
```
Rebuild initramfs to use:

```bash
make build_initramfs
reboot
```

Any static errors will abort the build. Mis-configurations will not be caught.
Be sure to test while you still have physical access to the machine.

## Dropbear

`cloudflared-initramfs` can be combined with dropbear to enable remote system
unlocking without needing control over the remote network, or knowing what the
public IP of that system is. It also creates an encrypted no-trust tunnel
before SSH connections are attempted.

### Requirements

1. [Dropbear](https://github.com/mkj/dropbear) installed, configured and in a
   "known working" state.

### Configure

Set dropbear to use *all* network interfaces to ensure remote unlocks work over
cloudflared tunnel first. Then restrict to the cloudflared tunnel once it is working:

`/etc/dropbear/initramfs/dropbear.conf`

```bash
DROPBEAR_OPTIONS='... -p 127.0.0.1:2222 ...'
```
Remember to point cloudflare tunnel to configured dropbear ssh port

`ssh://127.0.0.1:2222`

### SSH Config
`~/.ssh/config`
```
Host <cloudflare tunnel endpoint>
        ProxyCommand sudo /path/to/cloudflared access ssh --hostname %h
```
`ssh -i ~./ssh/<dropbear ssh key> root@<cloudflare tunnel endpoing> `

## Bug / Patches / Contributions?

All are welcome, please submit a pull request or open a bug!
