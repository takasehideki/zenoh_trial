# zenoh_trial

Quick trial a.k.a practice for the power of Zenoh :D

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

## Tool versions (in Docker)

- Ubuntu 22.04
- Zenoh v0.10.1-rc
- Rust 1.75.0
- Python 3.10.12
- Erlang/OTP 26.1.1
- Elixir 

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
