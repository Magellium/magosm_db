FROM postgres:12

###
# Set WORKDIR
###

ENV INSTALLWORKDIR /var/install
RUN mkdir $INSTALLWORKDIR
WORKDIR $INSTALLWORKDIR

###
# Environment variables
###

ENV POSTGIS_VERSION 2.5
ENV OSM2PGSQL_VERSION 1.2.0
ENV OSMOSIS_VERSION 0.47-4
ENV OSMIUM_VERSION 2.15.4
ENV OSMIUM_TOOL_VERSION 1.11.1

###
# Install dependencies
###

RUN \
    apt-get update && apt-get install -y --no-install-recommends \
    # utils
    wget \ 
    git \
    unzip \
    software-properties-common \
    # postgis
    postgresql-${PG_MAJOR}-postgis-${POSTGIS_VERSION} \
    postgresql-${PG_MAJOR}-postgis-${POSTGIS_VERSION}-scripts \
    # osm2pgsql - osmium common dependencies
    make cmake  g++ libboost-dev libbz2-dev \
    libexpat1-dev libproj-dev libsparsehash-dev \
    ruby ruby-json \
    spatialite-bin zlib1g-dev \
    # osm2pgsql
    libboost-system-dev \
    libboost-filesystem-dev \
    libpq-dev \
    lua5.2 liblua5.2-dev \
    # osmium
    doxygen graphviz libgdal-dev \
    libboost-program-options-dev libgeos++-dev \
    # then clean
    && rm -rf /var/lib/apt/lists/*


###
# Install dependencies from buster-backports
###

RUN \
    echo "deb http://deb.debian.org/debian buster-backports main contrib non-free" >> /etc/apt/sources.list.d/backports.list

RUN \
    apt-get update && apt-get install -y --no-install-recommends -t buster-backports \
    postgresql-pltcl-12 \
    # then clean
    && rm -rf /var/lib/apt/lists/*

###
# Install osm2pgsql
###

RUN wget https://github.com/openstreetmap/osm2pgsql/archive/${OSM2PGSQL_VERSION}.zip && \
    unzip ${OSM2PGSQL_VERSION}.zip && \
    rm ${OSM2PGSQL_VERSION}.zip && \
    cd osm2pgsql-${OSM2PGSQL_VERSION} && mkdir build && cd build && \
    cmake .. && make && make install

###
# Install osmium
###

# libosmium

RUN git clone https://github.com/mapbox/protozero && \
    wget https://github.com/osmcode/libosmium/archive/v${OSMIUM_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_VERSION}.tar.gz && \
    rm v${OSMIUM_VERSION}.tar.gz && \
    mv libosmium-${OSMIUM_VERSION} libosmium

RUN cd libosmium && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_TESTING=OFF -DINSTALL_PROTOZERO=ON .. && \
    make

# osmium-tool

RUN wget https://github.com/osmcode/osmium-tool/archive/v${OSMIUM_TOOL_VERSION}.tar.gz && \
    tar xzvf v${OSMIUM_TOOL_VERSION}.tar.gz && rm v${OSMIUM_TOOL_VERSION}.tar.gz && \
    mv osmium-tool-${OSMIUM_TOOL_VERSION} osmium-tool

RUN cd osmium-tool && \
    mkdir build && cd build && \
    cmake -DOSMIUM_INCLUDE_DIR=/var/install/libosmium/include/ .. && \
    make

RUN mv /var/install/osmium-tool/build/src/osmium /usr/bin/osmium

###
# Install osmosis
###

RUN \
    apt-get update && apt-get install -y --no-install-recommends \
    # osmosis
    osmosis=${OSMOSIS_VERSION} -V \
    # then clean
    && rm -rf /var/lib/apt/lists/*

###
# Clean
###

RUN \
    apt-get update &&  apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

