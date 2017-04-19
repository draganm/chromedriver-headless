FROM ubuntu:16.04

RUN apt-get update && apt-get install -yq libpangocairo-1.0-0 \
  libxcomposite1 \
  libxcursor1 \
  libxi6 \
  libxtst6 \
  libnss3 \
  libcups2 \
  libgconf-2-4 \
  libxss1 \
  libxrandr2 \
  libatk1.0-0 \
  libgtk2.0-0 \
  libasound2 \
  unzip \
  libx11-xcb1 \
  wget \
  build-essential \
	libpq-dev \
	git \
	openssh-client \
  software-properties-common \
  xvfb

RUN \
  wget 'https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F447231%2Fchrome-linux.zip?generation=1485873721531406&alt=media' && \
  unzip Linux_x64* && \
  rm Linux_x64*

RUN chmod 4755 chrome-linux/chrome_sandbox

RUN \
  wget https://chromedriver.storage.googleapis.com/2.29/chromedriver_linux64.zip && \
  unzip chromedriver_linux64.zip && \
  rm chromedriver_linux64.zip && \
  mv chromedriver /usr/bin

RUN \
	apt-add-repository -y ppa:brightbox/ruby-ng && \
	apt-get update -qy && \
	apt-get install -qy ruby${RUBY_MAJOR} ruby${RUBY_MAJOR}-dev

ENV RUBY_MAJOR 2.3
ENV RUBYGEMS_VERSION 2.6.7
ENV BUNDLER_VERSION 1.13.2

RUN { echo 'install: --no-document'; echo 'update: --no-document'; } >> /etc/gemrc

RUN	gem update --system "$RUBYGEMS_VERSION"

RUN gem install bundler --version "$BUNDLER_VERSION"

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
	BUNDLE_BIN="$GEM_HOME/bin" \
	BUNDLE_SILENCE_ROOT_WARNING=1 \
	BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" \
	&& chmod 777 "$GEM_HOME" "$BUNDLE_BIN"

ENV BUS_SESSION_BUS_ADDRESS=/dev/null

ENV DISPLAY :99
ADD xvfb_init /etc/init.d/xvfb
RUN chmod a+x /etc/init.d/xvfb
ADD xvfb-daemon-run /usr/bin/xvfb-daemon-run
RUN chmod a+x /usr/bin/xvfb-daemon-run
ENTRYPOINT ["/usr/bin/xvfb-daemon-run"]
