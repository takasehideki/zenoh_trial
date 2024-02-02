# zenoh_trial

Quick trial a.k.a practice to learn the power of Zenoh :D

## Tool versions (installed in Docker)

- Ubuntu 22.04 (base image)
- Zenoh v0.10.1-rc
- Rust 1.75.0
- Python 3.10.12
- Erlang/OTP 26.1.1
- Elixir 1.15.7-otp-26
- Mosquitto version 2.0.11
- CycloneDDS 0.10.4

## Prepare Docker env

### Build the image and use it locally

If you want to try this repo on the x64 machine, please enjoy the coffee break because building the image may take too long time :-

```
cd <git_cloned_dir>
docker build -t zenoh_trial .
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial zenoh_trial
```

### Quickstart by Docker Hub image

Currently, the operation in the pre-built Docker image is confirmed only on my M1 Mac (arm64) machine,,,
IOW, you are lucky if you also have it.

```
cd <git_cloned_dir>
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial takasehideki/zenoh_trial
```

#### MEMO for ME: build and push the image to Docker Hub

Since the Elixir build failed for amd64 on M1Mac, I am required to operate the below on the x64/Ubuntu machine,,,

```
docker build -t takasehideki/zenoh_trial . --push
```

#### WiP!: build and push the multi-platform images to Docker Hub

Unfortunately, I could not finish the below operation yet since the Elixir build failed for another target (for amd64 on M1Mac, or arm64 on x64/Ubuntu machine).

```
docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx build --platform linux/amd64,linux/arm64 -t takasehideki/zenoh_trial . --push
```

## Communication between anywhere in programming languages

### zenoh_native

Zenoh nodes (natively) implemented in Rust.  
The Source code is referred to https://docs.rs/zenoh/0.10.1-rc/zenoh/#examples

- Build
```
cd zenoh_native
cargo build
```

If the first build fails in Docker env, just try it again ;(

- Run
```
./target/debug/pub
```
```
./target/debug/sub
```

### zenoh_python

Zenoh nodes implemented in Python.  
The Source code is referred to https://zenoh.io/docs/getting-started/first-app/

- Run
```
cd zenoh_python
python3 pub.py
```
```
cd zenoh_python
python3 sub.py
```

### zenoh_elixir

Zenoh nodes implemented in Elixir :-

- Build
```
cd zenoh_elixir
mix deps.get
mix compile
```

- Run
```
iex -S mix
iex()> ZenohElixir.Pub.main
```
```
iex -S mix
iex()> ZenohElixir.Sub.main
```

## Communicate from inside and outside the Docker container

Communicating with each other from inside and outside of containers is not easy in the default Docker environment.
However, this can be established surprisingly quickly with the power of the Zenoh router:D

To run this demo, the host must also have Zenoh (zenohd) installed ([how to install it](https://github.com/eclipse-zenoh/zenoh?tab=readme-ov-file#how-to-install-it)).
Also, please confirm the IPv4 address (`<host_ip>`) of the host, e.g., `ifconfig en0`.

- 1st terminal on the **host**:
```
python3 zenoh_python/pub.py
```
- 2nd terminal on the _container_:
```
python3 zenoh_python/sub.py
```
- 3rd terminal on the **host**:
```
zenohd
```
- 4th terminal on the _container_:
```
zenohd -e tcp/<host_ip>:7447
```

## Communicate with another stack!

### MQTT

To confirm the marriage of Zenoh and MQTT, download the appropriate target `zenoh-bridge-mqtt` executable from [its Releases](https://github.com/eclipse-zenoh/zenoh-plugin-mqtt/releases/tag/0.10.1-rc) and locate it to `zenoh_mqtt/``.  
Then, try the following operations!

- 1st terminal (bridge):
```
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial --name zenoh_bridge takasehideki/zenoh_trial
./zenoh_mqtt/zenoh-bridge-mqtt
```
- 2nd terminal (MQTT subscriber):
```
docker exec -it zenoh_bridge /bin/bash
mosquitto_sub -d -t key/expression
```
- 3rd terminal (Zenoh publisher):
```
docker exec -it zenoh_bridge /bin/bash
python3 zenoh_python/pub.py
```

### DDS

Sure thing!
Zenoh can also chat with DDS (along with MQTT).

To confirm the marriage of Zenoh and DDS, download the appropriate target `zenoh-bridge-dds` executable from [its Releases](https://github.com/eclipse-zenoh/zenoh-plugin-dds/releases/tag/0.10.1-rc) and locate it to `zenoh_dds/``.  
Then, try the following operations, following the previous section!

- 4th terminal (bridge):
```
docker exec -it zenoh_bridge /bin/bash
./zenoh_dds/zenoh-bridge-dds
```
- 5th terminal (DDS publisher):
```
docker exec -it zenoh_bridge /bin/bash
python3 zenoh_dds/pub.py
```

### [MEMO for ME] standalone operation to confirm the Mosquitto MQTT.

- 1st terminal (broker):
```
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial --name zenoh_mqtt takasehideki/zenoh_trial
mosquitto -c zenoh_mqtt/mqtt_standalone.conf
```
- 2nd terminal (subscriber):
```
docker exec -it zenoh_mqtt /bin/bash
mosquitto_sub -d -t key/expression
```
- 3rd terminal (publisher):
```
docker exec -it zenoh_mqtt /bin/bash
mosquitto_pub -d -t key/expression -m "Hello from MQTT!!"
```
