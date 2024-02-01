FROM ubuntu:22.04

# Preparation
RUN apt-get update && apt-get install -y \
  ca-certificates curl build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Zenoh
RUN echo "deb [trusted=yes] https://download.eclipse.org/zenoh/debian-repo/ /" | tee -a /etc/apt/sources.list.d/zenoh.list > /dev/null
RUN apt-get update && apt-get install -y \
  zenoh \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH $PATH:$HOME/.cargo/env

# Install Python & zenoh-python
RUN apt-get update && apt-get install -y \
  python3.11 python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN pip install -U pip && \
  pip install --no-cache-dir eclipse-zenoh

CMD ["/bin/bash"]
