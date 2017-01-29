FROM python:2.7

LABEL maintainer "gaetancollaud@gmail.com"

EXPOSE 5000

ENV CURA_VERSION=15.04.6
ARG tag=master

VOLUME /user/octoprint/.octoprint

WORKDIR /opt/octoprint

# In case of alpine
#RUN apk update && apk upgrade \
#    && apk add --no-cache bash git openssh gcc\
#		&& pip install virtualenv \
#		&& rm -rf /var/cache/apk/*

#install ffmpeg
RUN cd /tmp \
  && wget -O ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-32bit-static.tar.xz \
	&& mkdir -p /opt/ffmpeg \
	&& tar xvf ffmpeg.tar.xz -C /opt/ffmpeg --strip-components=1 \
  && rm -Rf /tmp/*

#install Cura
RUN cd /tmp \
  && wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && tar -zxf ${CURA_VERSION}.tar.gz \
	&& cd CuraEngine-${CURA_VERSION} \
	&& mkdir build \
	&& make \
	&& mv -f ./build /opt/cura/ \
  && rm -Rf /tmp/*

#Install Octoprint
RUN git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
	&& ./venv/bin/python setup.py install

#Create an octoprint user
RUN useradd -ms /bin/bash octoprint && adduser octoprint dialout
USER octoprint

CMD ["/opt/octoprint/venv/bin/octoprint serve"]
