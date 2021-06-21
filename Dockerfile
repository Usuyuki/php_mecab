FROM php:7.4.12-fpm-alpine

## ここから
# https://qiita.com/nownabe/items/4171776aec1f05de9f28#dockerfile
RUN apk add --update --no-cache build-base

ENV MECAB_VERSION 0.996
ENV IPADIC_VERSION 2.7.0-20070801
ENV mecab_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE
ENV ipadic_url https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM
ENV build_deps 'curl git bash file sudo openssh'
ENV dependencies 'openssl'

RUN apk add --update --no-cache ${build_deps} \
  # Install dependencies
  && apk add --update --no-cache ${dependencies} \
  # Install MeCab
  && curl -SL -o mecab-${MECAB_VERSION}.tar.gz ${mecab_url} \
  && tar zxf mecab-${MECAB_VERSION}.tar.gz \
  && cd mecab-${MECAB_VERSION} \
  && ./configure --enable-utf8-only --with-charset=utf8 \
  && make \
  && make install \
  && cd \
  # Install IPA dic
  && curl -SL -o mecab-ipadic-${IPADIC_VERSION}.tar.gz ${ipadic_url} \
  && tar zxf mecab-ipadic-${IPADIC_VERSION}.tar.gz \
  && cd mecab-ipadic-${IPADIC_VERSION} \
  && ./configure --with-charset=utf8 \
  && make \
  && make install \
  && cd \
  # Install Neologd
  && git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git \
  && mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y \
  # Clean up
  && apk del ${build_deps} \
  && rm -rf \
    mecab-${MECAB_VERSION}* \
    mecab-${IPADIC_VERSION}* \
    mecab-ipadic-neologd

## ここまで

## ここから追記する
ENV build_deps_phpmecab 'git autoconf'
COPY php.mecab.ini /usr/local/etc/php/conf.d/
RUN apk add --update --no-cache ${build_deps_phpmecab} \ 
  && git clone https://github.com/rsky/php-mecab.git \
  && cd ./php-mecab/mecab \
  && phpize \
  && ./configure --with-php-config=/usr/local/bin/php-config --with-mecab=/usr/local/bin/mecab-config \
  && make \
  && make test \
  && make install \
  # Clean up
  && cd  \
  && rm -rf php-mecab \
  && apk del ${build_deps_phpmecab}

# ▼▼このコマンドが最後に来るようにしてください
RUN docker-php-ext-install pdo pdo_mysql