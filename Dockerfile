FROM python:3.10-slim-bullseye

LABEL title=ultra
LABEL version="0.2"

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ARG USERNAME=sp
ARG CREDENTIALS_FILE=.config/gcloud/application_default_credentials.json
ARG SRC_CREDENTIALS_DIR=/Users/hongseungpyo
ARG DST_CRENDENTIALS_DIR=/home/${USERNAME}

RUN apt-get -y update && \
apt-get install -y net-tools zsh vim curl wget git sudo unzip && \
adduser --disabled-password --gecos "" ${USERNAME} && \
usermod -aG sudo ${USERNAME} && \
echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
chsh -s /bin/zsh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ARG GOOGLE_SDK_URL=https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-410.0.0-linux-x86_64.tar.gz
ARG GOOGLE_SDK_TAR=google-cloud-cli-410.0.0-linux-x86_64.tar.gz
RUN curl -O ${GOOGLE_SDK_URL} && \
tar -xf ${GOOGLE_SDK_TAR} && \
rm -rf ${GOOGLE_SDK_TAR} && \
{echo n; echo y; echo /home/${USERNAME}/.zshrc} | /home/sp/google-cloud-sdk/install.sh && \
pip install google-cloud-bigquery pandas db-dtypes
ENV PATH ${PATH}:/home/${USERNAME}/google-cloud-sdk/bin
ENV GOOGLE_APPLICATION_CREDENTIALS /home/${USERNAME}/.config/gcloud/application_default_credentials.json

# Content of cavern.sh

# flag_file=".gcloud.lock"
# if [ ! -e "$flag_file" ]; then
#     gcloud init
#     gcloud auth application-default login
#     echo "Command executed"
#     touch "$flag_file"
# fi

COPY cavern.sh /home/${USERNAME}/cavern.sh
RUN cat /home/${USERNAME}/cavern.sh | tee -a /home/${USERNAME}/.zshrc && \
rm -rf /home/${USERNAME}/cavern.sh && \
yes | sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ENTRYPOINT [ "/bin/zsh" ]
