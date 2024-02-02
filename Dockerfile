FROM ubuntu:22.04

# Install Zenoh
RUN apt-get update && apt-get install -y \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN echo "deb [trusted=yes] https://download.eclipse.org/zenoh/debian-repo/ /" | tee -a /etc/apt/sources.list.d/zenoh.list > /dev/null
RUN apt-get update && apt-get install -y \
  zenoh \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN apt-get update && apt-get install -y \
  curl build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH $PATH:$HOME/.cargo/env

# Install Python & zenoh-python
RUN apt-get update && apt-get install -y \
  python3.11 python3-pip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
RUN pip install -U pip && \
  pip install --no-cache-dir eclipse-zenoh

# Install Erlang
RUN apt-get update && apt-get install -y \
  autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV OTP_VERSION="26.1.1"
RUN set -xe \
	&& OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz" \
	&& OTP_DOWNLOAD_SHA256="a47203930e4b34a0e23bdf0a968127e5ec9d0e6c69ccf2e53be81cd2360eee2d" \
	&& runtimeDeps='libodbc1 \
			libsctp1 \
			libwxgtk3.0 \
			libwxgtk-webview3.0-gtk3-0v5' \
	&& buildDeps='unixodbc-dev \
			libsctp-dev \
			libwxgtk-webview3.0-gtk3-dev' \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends $runtimeDeps \
	&& apt-get install -y --no-install-recommends $buildDeps \
	&& curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" \
	&& echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - \
	&& export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" \
	&& mkdir -vp $ERL_TOP \
	&& tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 \
	&& rm otp-src.tar.gz \
	&& ( cd $ERL_TOP \
	  && ./otp_build autoconf \
	  && gnuArch="$(dpkg-architecture --query DEB_HOST_GNU_TYPE)" \
	  && ./configure --build="$gnuArch" \
	  && make -j$(nproc) \
	  && make -j$(nproc) docs DOC_TARGETS=chunks \
	  && make install install-docs DOC_TARGETS=chunks ) \
	&& find /usr/local -name examples | xargs rm -rf \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& rm -rf $ERL_TOP /var/lib/apt/lists/*

# Install Elixir
ENV ELIXIR_VERSION="v1.15.7" \
	LANG=C.UTF-8
RUN set -xe \
	&& ELIXIR_DOWNLOAD_URL="https://github.com/elixir-lang/elixir/archive/${ELIXIR_VERSION}.tar.gz" \
	&& ELIXIR_DOWNLOAD_SHA256="78bde2786b395515ae1eaa7d26faa7edfdd6632bfcfcd75bccb6341a18e8798f" \
	&& curl -fSL -o elixir-src.tar.gz $ELIXIR_DOWNLOAD_URL \
	&& echo "$ELIXIR_DOWNLOAD_SHA256  elixir-src.tar.gz" | sha256sum -c - \
	&& mkdir -p /usr/local/src/elixir \
	&& tar -xzC /usr/local/src/elixir --strip-components=1 -f elixir-src.tar.gz \
	&& rm elixir-src.tar.gz \
	&& cd /usr/local/src/elixir \
	&& make install clean \
	&& find /usr/local/src/elixir/ -type f -not -regex "/usr/local/src/elixir/lib/[^\/]*/lib.*" -exec rm -rf {} + \
	&& find /usr/local/src/elixir/ -type d -depth -empty -delete

# Install Mosquitto MQTT
RUN apt-get update && apt-get install -y \
  mosquitto mosquitto-clients \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install CycloneDDS
RUN apt-get update && apt-get install -y \
  cmake \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
ENV CDDS_VERSION="0.10.4" \
	LANG=C.UTF-8
RUN set -xe \
	&& CDDS_DOWNLOAD_URL="https://github.com/eclipse-cyclonedds/cyclonedds/archive/refs/tags/${CDDS_VERSION}.tar.gz" \
	&& curl -fSL -o cyclonedds-src.tar.gz $CDDS_DOWNLOAD_URL \
	&& mkdir -p /usr/local/src/cyclonedds \
	&& tar -xzC /usr/local/src/cyclonedds --strip-components=1 -f cyclonedds-src.tar.gz \
	&& rm cyclonedds-src.tar.gz \
	&& cd /usr/local/src/cyclonedds \
	&& mkdir -p build \
	&& cd /usr/local/src/cyclonedds/build \
  && cmake -DCMAKE_INSTALL_PREFIX=/usr/local/cyclonedds .. \
  && cmake --build . --target install \
	&& find /usr/local/src/cyclonedds/ -type f -not -regex "/usr/local/src/cyclonedds/lib/[^\/]*/lib.*" -exec rm -rf {} + \
	&& find /usr/local/src/cyclonedds/ -type d -depth -empty -delete
ENV CYCLONEDDS_HOME /usr/local/cyclonedds

# Install CycloneDDS Python binding
RUN pip install -U pip && \
  pip install --no-cache-dir cyclonedds

CMD ["/bin/bash"]
