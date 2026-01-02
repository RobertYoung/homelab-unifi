FROM debian:12

RUN apt-get update && \
  apt-get install -y curl zip unzip less vim tar gnupg && \
  curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/4.4 main" > /etc/apt/sources.list.d/mongodb-org-4.4.list && \
  apt-get update && \
  apt-get install -y mongodb-database-tools && \
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY backup.sh .

RUN chmod +x backup.sh
