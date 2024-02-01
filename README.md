# zenoh_trial
Quick trial a.k.a practice for the power of Zenoh :D

## Prepare Docker env

```
cd <git_cloned_dir>
docker build -t zenoh_trial .
docker run -it --rm -v `pwd`:/zenoh_trial -w /zenoh_trial zenoh_trial
```

## zenoh_native

Zenoh nodes (natively) implemented in Rust.  
Source code is referred to https://docs.rs/zenoh/0.10.1-rc/zenoh/#examples

- Build
```
cd zenoh_native
cargo build
```

- Run
```
./target/debug/pub_rust
```
```
./target/debug/sub_rust
```

## zenoh_python

Zenoh nodes implemented in Python.  
Source code is referred to https://zenoh.io/docs/getting-started/first-app/

- Run
```
cd zenoh_python
python3 pub.py
```
```
cd zenoh_python
python3 sub.py
```
