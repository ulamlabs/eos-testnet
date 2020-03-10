FROM eostudio/eos:v1.8.12

RUN cd /tmp && \
    wget https://github.com/eosio/eosio.cdt/releases/download/v1.6.3/eosio.cdt_1.6.3-1-ubuntu-18.04_amd64.deb && \
    apt install ./eosio.cdt_1.6.3-1-ubuntu-18.04_amd64.deb

RUN apt -yq update && apt -yq install git cmake g++ gettext-base

RUN cd /tmp && \
    git clone https://github.com/EOSIO/eosio.contracts.git --branch v1.8.3 --single-branch && \
    cd eosio.contracts && \
    ./build.sh -y

ADD . /app

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["start"]