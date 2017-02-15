FROM nwdrone/aarch64-odm:latest
MAINTAINER Tyler Baker <forcedinductionz@gmail.com>

EXPOSE 3000

USER root
RUN \
  curl https://nodejs.org/dist/v6.9.5/node-v6.9.5-linux-arm64.tar.xz > node-v6.9.5-linux-arm64.tar.xz && \
  tar -C . -xaf node-v6.9.5-linux-arm64.tar.xz && \
  rm node-v6.9.5-linux-arm64.tar.xz && \
  cd node-v6.9.5-linux-arm64 && \
  cp -R * /usr/local/
RUN apt-get install -y python-gdal libboost-dev libboost-program-options-dev
RUN npm install -g nodemon

# Build LASzip and PotreeConverter
WORKDIR "/staging"
RUN git clone https://github.com/pierotofy/LAStools /staging/LAStools && \
	cd LAStools/LASzip && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release .. && \
	make && \
	make install && \
	ldconfig

RUN git clone https://github.com/pierotofy/PotreeConverter /staging/PotreeConverter
RUN cd /staging/PotreeConverter && \
	mkdir build && \
	cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DLASZIP_INCLUDE_DIRS=/staging/LAStools/LASzip/dll -DLASZIP_LIBRARY=/staging/LAStools/LASzip/build/src/liblaszip.so .. && \
	make && \
	make install

RUN mkdir /var/www

WORKDIR "/var/www"
RUN git clone https://github.com/pierotofy/node-OpenDroneMap .
RUN npm install

# Fix old version of gdal2tiles.py
RUN (cd / && patch -p0) <patches/gdal2tiles.patch

ENTRYPOINT ["node", "/var/www/index.js"]
