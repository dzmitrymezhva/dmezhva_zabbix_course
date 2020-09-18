#! /bin/bash
prometheus_ip=
mail_pass=
node_exporter_ip=
## installing docker and docker-compose on Centos 7
# install the yum-utils package (which provides the yum-config-manager utility)
sudo yum install -y yum-utils

# add repo to install docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install docker and docker-compose
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose

# set docker to start automatically at boot time
sudo systemctl enable docker

# start docker daemon
sudo systemctl start docker

## installing prometheus, blackbox, alertmanager and grafana with docker compose file
# create prometheus config file
sudo tee /tmp/prometheus.yml << EOF
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s
rule_files:
  - rules.yml
alerting:
  alertmanagers:
  - scheme: http
    static_configs:
    - targets:
      - alertmanager:9093
scrape_configs:
- job_name: prometheus
  static_configs:
  - targets:
    - prometheus:9090
- job_name: node_exporter
  static_configs:
  - targets:
    - $node_exporter_ip:9100
- job_name: blackbox
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
        - https://onliner.by
  relabel_configs:
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox:9115
EOF

# create aleetmanager config file
cat << EOF > /tmp/config.yml
route:
  receiver: email
receivers:
- name: email
  email_configs:
  - to: dzmitry_mezhva@epam.com
    from: dzmitry.mezhva@gmail.com
    smarthost: smtp.gmail.com:465
    auth_username: dzmitry.mezhva@gmail.com
    auth_identity: dzmitry.mezhva@gmail.com
    auth_password: $mail_pass
EOF

# creating alert rule
sudo tee /tmp/rules.yml << EOF
groups:
- name: AllInstances
  rules:
  - alert: InstanceDown
    # Condition for alerting
    expr: up == 0
    for: 1m
    # Annotation - additional informational labels to store more information
    annotations:
      title: 'Instance {{ $labels.instance }} down'
      description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 1 minute.'
    # Labels - additional labels to be attached to the alert
    labels:
        severity: 'critical'
EOF
sudo sleep 20
# crerate docker compose file
sudo tee /tmp/docker-compose.yaml << EOF
version: '3.2'
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: on-failure
    ports:
    - 9090:9090
    command:
    - --config.file=/etc/prometheus/prometheus.yml
    volumes:
    - /tmp/prometheus.yml:/etc/prometheus/prometheus.yml
    - /tmp/rules.yml:/etc/prometheus/rules.yml
  blackbox:
    image: prom/blackbox-exporter:latest
    container_name: blackbox
    restart: on-failure
    ports:
    - 9115:9115
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: on-failure
    ports:
    - 3000:3000
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    restart: on-failure
    ports:
    - 9093:9093
    command:
    - --config.file=/etc/alertmanager/config.yml
    volumes:
    - /tmp/config.yml:/etc/alertmanager/config.yml
EOF

# run docker compose file
cd /tmp/
sudo docker-compose up -d

# add prometheus to grafana
#sudo sleep 30
#curl -X POST http://admin:admin@localhost:3000/api/datasources -H "Content-Type: application/json;charset=UTF-8" --data-binary \
#'{"name":"Prometheus","type":"prometheus","url":"http://$prometheus_ip:9090","access":"proxy","isDefault":true}'