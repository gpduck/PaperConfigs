from amazoncorretto:16-alpine

ADD install-pwsh.sh /
RUN chmod +x /install-pwsh.sh && /install-pwsh.sh

RUN mkdir /paper \
    && mkdir /server \
    && echo 'eula=true' > /server/eula.txt
#ADD https://papermc.io/api/v2/projects/paper/versions/1.17/builds/71/downloads/paper-1.17-71.jar /paper/paper.jar
ADD https://papermc.io/api/v2/projects/paper/versions/1.17/builds/79/downloads/paper-1.17-79.jar /paper/paper.jar
ADD startup.sh /paper/startup.sh
ADD server.properties /paper/
ADD plugins/ /paper/plugins/
RUN chmod +x /paper/startup.sh

VOLUME ["/server"]
EXPOSE 25565/tcp
EXPOSE 25565/udp

WORKDIR /server
ENV SERVER_NAME='Paper Server'
CMD /paper/startup.sh