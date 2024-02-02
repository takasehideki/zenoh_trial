# zenoh_trial
Quick trial a.k.a practice for the power of Zenoh :D

## Prepare Docker env

### Usage by Docker Hub image

```
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial takasehideki/zenoh_trial
```

### Build image locally

```
cd <git_cloned_dir>
docker build -t zenoh_trial .
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial zenoh_trial
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
