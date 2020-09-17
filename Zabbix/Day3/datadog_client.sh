#! /bin/bash

## Install The Datadog Agent
sudo DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${DD_API_KEY} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

## Web configuration
sudo cat > /etc/datadog-agent/conf.d/http_check.d/${site}.yaml << EOF
instances:
  - name: ${site}
    url: https://${site}
EOF

## Log configuration
sudo sed -i "s/# logs_enabled: false/logs_enabled: true/" /etc/datadog-agent/datadog.yaml
sudo mkdir /etc/datadog-agent/conf.d/gcp_test.d
sudo chown dd-agent:dd-agent /etc/datadog-agent/conf.d/gcp_test.d
sudo cat > ~/conf.yaml << EOF
#Log section
logs:

    # - type : (mandatory) type of log input source (tcp / udp / file)
    #   port / path : (mandatory) Set port if type is tcp or udp. Set path if type is file
    #   service : (mandatory) name of the service owning the log
    #   source : (mandatory) attribute that defines which integration is sending the log
    #   sourcecategory : (optional) Multiple value attribute. Can be used to refine the source attribute
    #   tags: (optional) add tags to each log collected

  - type: file
    path: /var/log/datadog/agent.log
    service: datadog
    source: datadog.agent
EOF
sudo cp ~/conf.yaml /etc/datadog-agent/conf.d/gcp_test.d/conf.yaml

## Restart datadog-agent to apply changes
sudo systemctl restart datadog-agent

