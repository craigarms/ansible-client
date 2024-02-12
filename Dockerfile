FROM debian:bookworm
RUN apt update && apt install -y tzdata; \
    apt clean;

# sshd
RUN mkdir /var/run/sshd; \
    apt install -y openssh-server; \
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config

RUN apt install -y python3
RUN apt install -y iproute2
RUN apt clean

RUN useradd -ms /bin/bash ansible

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'echo "ansible:${ANSIBLE_PASSWORD}" | chpasswd'; \
    echo 'sleep 2'; \
    echo "echo 'My IP' \$(ip add | grep inet | tail -n 1 | awk '/inet/ {print \$2}')"; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entrypoint.sh; \
    chmod +x /usr/local/bin/entrypoint.sh;

ENV TZ Europe/Paris

ENV ROOT_PASSWORD root
ENV ANSIBLE_PASSWORD ansiblepassword

EXPOSE 22

ENTRYPOINT ["entrypoint.sh"]
CMD    ["/usr/sbin/sshd", "-D", "-e"]