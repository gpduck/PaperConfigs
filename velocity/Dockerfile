from amazoncorretto:17-alpine

ADD install-pwsh.sh /
RUN chmod +x /install-pwsh.sh && /install-pwsh.sh

RUN mkdir /velocity
ADD https://papermc.io/api/v2/projects/velocity/versions/3.1.1/builds/98/downloads/velocity-3.1.1-98.jar /velocity/velocity.jar
ADD plugins/ /velocity/plugins/
ADD https://github.com/Sander0542/VelocityUtils/releases/download/v1.1.0/VelocityUtils-1.1.0.jar /velocity/plugins/
ADD https://storage4e4c489d.blob.core.windows.net/plugins/LuckPerms/LuckPerms-Velocity-5.4.5.jar /velocity/plugins/
ADD https://storage4e4c489d.blob.core.windows.net/plugins/VelocityParty/velocityparty-1.1.0.jar /velocity/plugins/
ADD startup.ps1 /velocity/startup.ps1
RUN chmod +x /velocity/startup.ps1
ADD velocity.toml /velocity/

VOLUME ["/etc/mcinfo"]
EXPOSE 25577/tcp
EXPOSE 25577/udp

ENV Xms='1G'
ENV Xmx='1G'

WORKDIR /velocity


CMD /velocity/startup.ps1