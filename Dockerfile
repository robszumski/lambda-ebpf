# Use the Amazon Linux 2023 Lambda base image
FROM public.ecr.aws/lambda/provided:al2023

# Install the EdgeBit agent
RUN dnf install -y jq go tar
RUN curl -sL $(curl -s https://api.github.com/repos/edgebitio/edgebit-agent/releases/latest | jq -r ".assets[] | select(.name|match(\"^edgebit-(.*)$(uname -m).rpm$\")) | .browser_download_url") -o edgebit-agent.rpm
RUN rpm -i edgebit-agent.rpm

# Write out the config file
COPY edgebit.yaml /etc/edgebit/config.yaml 

# Install Syft
COPY syft.yaml /opt/edgebit/syft.yaml
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Build the binary
# COPY . .
# RUN go mod init helloworld
# # RUN CGO_ENABLED=0 GOOS=linux go build -o /helloworld .
# RUN go build -o ./helloworld .

# Run the binary
# ENTRYPOINT [ "./helloworld" ]
ENTRYPOINT EDGEBIT_LOG_LEVEL=debug /opt/edgebit/edgebit-agent
# ENTRYPOINT /opt/edgebit/edgebit-agent
