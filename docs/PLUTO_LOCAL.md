# PlutoSDR at `pluto.local`

Dzwonnica SDR is preconfigured for an ADALM-Pluto exposed by libiio as `pluto.local`.

## Verify the receiver

Install SoapySDR and the SoapyPlutoSDR module, then run:

```bash
SoapySDRUtil --probe="driver=plutosdr,hostname=pluto.local"
```

On this installation `pluto.local` currently resolves to `192.168.68.59`. Verify
that address directly if mDNS is unavailable:

```bash
SoapySDRUtil --probe="driver=plutosdr,hostname=192.168.68.59"
```

The Docker Compose configuration maps `pluto.local` to `192.168.68.59` inside
the container, so it does not depend on container-side mDNS. If DHCP changes
the Pluto address, provide the new value when starting the service:

```bash
PLUTO_IP=192.168.68.59 docker compose up -d --build
```

## Native build and run

```bash
git submodule update --init --recursive
cd frontend && npm ci && npm run build && cd ..
cargo build -p novasdr-server --release --features soapysdr
./target/release/novasdr-server -c config/config.json -r config/receivers.json
```

Open `http://localhost:9002` locally or `http://HOST_LAN_IP:9002` from another
device on the same network. See [`LOCAL_NETWORK.md`](LOCAL_NETWORK.md).

## Docker

```bash
docker compose build
docker compose up -d
docker compose logs -f dzwonnica-sdr
```

The image builds SoapySDR and SoapyPlutoSDR from source and includes the required libiio/ad9361 runtime libraries.

## Adjusting the tuning range

Edit `config/receivers.json`:

- `frequency`: center frequency in Hz;
- `sps`: sample rate (the supplied value is `2400000`);
- `gain`: Pluto RX gain in dB;
- `defaults.frequency` and `defaults.modulation`: initial browser tuning.

After changing a mounted config file in Docker, restart the service with `docker compose restart dzwonnica-sdr`.
