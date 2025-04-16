#!/bin/bash

# Function to display the Prometheus/Grafana banner
show_prometheus_banner() {
    echo -e "\033[1;35m
+------------------+
|  MONITORING      |
|  Prometheus      |
|  Grafana         |
+------------------+
\033[1;34m
Version: 1.0.1\033[0m"
}

# Function to display the ELK Stack banner
show_elk_banner() {
    echo -e "\033[1;34m
+------------------+
|  ELK STACK       |
|  Elasticsearch   |
|  Logstash        |
|  Kibana          |
+------------------+
\033[1;34m
Version: 8.17.2\033[0m"
}

# Function to create configuration files
create_config_files() {
    echo "Creating configuration files..."

    # Create prometheus.yml
    cat <<EOL > prometheus.yml
global:
  scrape_interval: 3s  # Adjust as needed

scrape_configs:
  - job_name: 'ays-production-backend-ecs'
    metrics_path: '/public/actuator/prometheus'
    static_configs:
      - targets: ['host.docker.internal:9090']  

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
EOL

    # Create logstash.yml
    cat <<EOL > logstash.yml
http.host: "0.0.0.0"
xpack.monitoring.elasticsearch.hosts: [ "http://es01:9200" ]
EOL

    # Create logstash.conf
    cat <<EOL > logstash.conf
input {
  tcp {
    port => 5044
    codec => json_lines
  }
}

filter {}

output {
  elasticsearch {
    index => "logstash-%{+YYYY.MM.dd}"
    hosts => ["https://es01:9200"]
    user => "elastic"
    password => "elastic"
    ssl_enabled => true
    cacert => "/usr/share/logstash/certs/ca/ca.crt"
  }
  #stdout {}
}
EOL

    # Create initial docker-compose.yml
    cat <<EOL > docker-compose.yml
version: '3.8'

volumes:
  grafana-volume:
  prometheus-volume:
  certs:
    driver: local
  elasticdata:
    driver: local
  kibanadata:
    driver: local
  logstashdata:
    driver: local

networks:
  monitoring-network:
    driver: bridge
  elastic:
    driver: bridge

services:
  prometheus:
    container_name: prometheus
    image: prom/prometheus:\${PROMETHEUS_IMAGE_VERSION}
    restart: always
    ports:
      - "9090:9090"
    environment:
      - PROMETHEUS_CONFIG_PATH=\${PROMETHEUS_CONFIG_PATH}
    volumes:
      - ./prometheus-volume:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring-network

  node-exporter:
    container_name: node-exporter
    image: prom/node-exporter:\${NODE_EXPORTER_IMAGE_VERSION}
    restart: always
    ports:
      - "9100:9100"
    networks:
      - monitoring-network

  grafana:
    container_name: grafana
    image: grafana/grafana:\${GRAFANA_IMAGE_VERSION}
    restart: always
    environment:
      - GF_SECURITY_ADMIN_USER=\${GF_SECURITY_ADMIN_USER}
      - GF_SECURITY_ADMIN_PASSWORD=\${GF_SECURITY_ADMIN_PASSWORD}
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    volumes:
      - ./grafana-volume:/var/lib/grafana
      - ./grafana-volume/logs:/var/log/grafana
    networks:
      - monitoring-network

  setup:
    image: docker.elastic.co/elasticsearch/elasticsearch:\${STACK_VERSION}
    container_name: elk-setup-container
    volumes:
      - certs:/usr/share/elasticsearch/config/certs
    user: "0"
    command: >
      bash -c '
        if [ x\${ELASTIC_PASSWORD} == x ]; then
          echo "Set the ELASTIC_PASSWORD environment variable in the .env file";
          exit 1;
        elif [ x\${KIBANA_PASSWORD} == x ]; then
          echo "Set the KIBANA_PASSWORD environment variable in the .env file";
          exit 1;
        fi;
        if [ ! -f config/certs/ca.zip ]; then
          echo "Creating CA";
          bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
          unzip config/certs/ca.zip -d config/certs;
        fi;
        if [ ! -f config/certs/certs.zip ]; then
          echo "Creating certs";
          echo -ne \
          "instances:\n"\
          "  - name: es01\n"\
          "    dns:\n"\
          "      - es01\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          "  - name: kibana\n"\
          "    dns:\n"\
          "      - kibana\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          > config/certs/instances.yml;
          bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
          unzip config/certs/certs.zip -d config/certs;
        fi;
        echo "Setting file permissions"
        chown -R root:root config/certs;
        find . -type d -exec chmod 750 \{\} \;;
        find . -type f -exec chmod 640 \{\} \;;
        echo "Waiting for Elasticsearch availability";
        until curl -s --cacert config/certs/ca/ca.crt https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done;
        echo "Setting kibana_system password";
        until curl -s -X POST --cacert config/certs/ca/ca.crt -u "elastic:\${ELASTIC_PASSWORD}" -H "Content-Type: application/json" https://es01:9200/_security/user/kibana_system/_password -d "{\"password\":\"\${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done;
        echo "All done!";
      '
    healthcheck:
      test: ["CMD-SHELL", "[ -f config/certs/es01/es01.crt ]"]
      interval: 1s
      timeout: 5s
      retries: 120
    networks:
      - elastic

  es01:
    depends_on:
      setup:
        condition: service_healthy
    image: docker.elastic.co/elasticsearch/elasticsearch:\${STACK_VERSION}
    container_name: elasticsearch
    labels:
      co.elastic.logs/module: elasticsearch
    volumes:
      - certs:/usr/share/elasticsearch/config/certs
      - elasticdata:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
    environment:
      - node.name=es01
      - cluster.name=\${CLUSTER_NAME}
      - cluster.initial_master_nodes=es01
      - discovery.seed_hosts=e01
      - ELASTIC_PASSWORD=\${ELASTIC_PASSWORD}
      - bootstrap.memory_lock=true
      - xpack.security.enabled=true
      - xpack.security.http.ssl.enabled=true
      - xpack.security.http.ssl.key=certs/es01/es01.key
      - xpack.security.http.ssl.certificate=certs/es01/es01.crt
      - xpack.security.http.ssl.certificate_authorities=certs/ca/ca.crt
      - xpack.security.transport.ssl.enabled=true
      - xpack.security.transport.ssl.key=certs/es01/es01.key
      - xpack.security.transport.ssl.certificate=certs/es01/es01.crt
      - xpack.security.transport.ssl.certificate_authorities=certs/ca/ca.crt
      - xpack.security.transport.ssl.verification_mode=certificate
      - xpack.license.self_generated.type=\${LICENSE}
    mem_limit: \${ES_MEM_LIMIT}
    ulimits:
      memlock:
        soft: -1
        hard: -1
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s --cacert config/certs/ca/ca.crt https://localhost:9200 | grep -q 'missing authentication credentials'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120
    networks:
      - elastic

  kibana:
    depends_on:
      es01:
        condition: service_healthy
    image: docker.elastic.co/kibana/kibana:\${STACK_VERSION}
    container_name: kibana
    labels:
      co.elastic.logs/module: kibana
    volumes:
      - certs:/usr/share/kibana/config/certs
      - kibanadata:/usr/share/kibana/data
    ports:
      - \${KIBANA_PORT}:5601
    environment:
      - SERVERNAME=kibana
      - ELASTICSEARCH_HOSTS=https://es01:9200
      - ELASTICSEARCH_USERNAME=kibana_system
      - ELASTICSEARCH_PASSWORD=\${KIBANA_PASSWORD}
      - ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=config/certs/ca/ca.crt
      - XPACK_SECURITY_ENCRYPTIONKEY=\${ENCRYPTION_KEY}
      - XPACK_ENCRYPTEDSAVEDOBJECTS_ENCRYPTIONKEY=\${ENCRYPTION_KEY}
      - XPACK_REPORTING_ENCRYPTIONKEY=\${ENCRYPTION_KEY}
    mem_limit: \${KB_MEM_LIMIT}
    healthcheck:
      test:
        [
          "CMD-SHELL",
          "curl -s -I http://localhost:5601 | grep -q 'HTTP/1.1 302 Found'",
        ]
      interval: 10s
      timeout: 10s
      retries: 120
    networks:
      - elastic

  logstash:
    depends_on:
      es01:
        condition: service_healthy
      kibana:
        condition: service_healthy
    image: docker.elastic.co/logstash/logstash:\${STACK_VERSION}
    container_name: logstash
    labels:
      co.elastic.logs/module: logstash
    user: root
    volumes:
      - logstashdata:/usr/share/logstash/data
      - certs:/usr/share/logstash/certs
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
      - ./logstash.yml:/usr/share/logstash/config/logstash.yml:ro
    environment:
      - NODE_NAME="logstash"
      - xpack.monitoring.enabled=false
      - ELASTIC_USER=elastic
      - ELASTIC_PASSWORD=\${ELASTIC_PASSWORD}
      - ELASTIC_HOSTS=https://es01:9200
    command: logstash -f /usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
    mem_limit: \${LS_MEM_LIMIT}
    networks:
      - elastic
EOL

    echo "Configuration files created successfully!"
}

# Function to setup Prometheus and Grafana
setup_prometheus_grafana() {
    show_prometheus_banner
    
    echo -e "\033[1;34m🧑‍💼 Enter Grafana Admin Username (GF_SECURITY_ADMIN_USER) [default: admin]: \033[0m"
    read GF_SECURITY_ADMIN_USER
    GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER:-admin}

    echo -e "\033[1;34m🔑 Enter Grafana Admin Password (GF_SECURITY_ADMIN_PASSWORD) [default: admin]: \033[0m"
    read -s GF_SECURITY_ADMIN_PASSWORD
    GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD:-admin}

    echo -e "\033[1;34m🐳 Enter Prometheus Image Version (PROMETHEUS_IMAGE_VERSION) [default: v3.2.0]: \033[0m"
    read PROMETHEUS_IMAGE_VERSION
    PROMETHEUS_IMAGE_VERSION=${PROMETHEUS_IMAGE_VERSION:-v3.2.0}

    echo -e "\033[1;34m🐳 Enter Node Exporter Image Version (NODE_EXPORTER_IMAGE_VERSION) [default: v1.8.2]: \033[0m"
    read NODE_EXPORTER_IMAGE_VERSION
    NODE_EXPORTER_IMAGE_VERSION=${NODE_EXPORTER_IMAGE_VERSION:-v1.8.2}

    echo -e "\033[1;34m🐳 Enter Grafana Image Version (GRAFANA_IMAGE_VERSION) [default: 11.5.2-ubuntu]: \033[0m"
    read GRAFANA_IMAGE_VERSION
    GRAFANA_IMAGE_VERSION=${GRAFANA_IMAGE_VERSION:-11.5.2-ubuntu}

    # Create directories for volumes
    mkdir -p ./grafana-volume ./prometheus-volume
    chmod 775 ./grafana-volume ./prometheus-volume

    # Start Docker Compose for Prometheus/Grafana
    echo "Starting Prometheus/Grafana containers..."
    docker compose -p monitoring --env-file .env up -d prometheus node-exporter grafana
}

# Function to setup ELK Stack
setup_elk_stack() {
    show_elk_banner

    # Default values for ELK Stack
    ELASTIC_PASSWORD=${ELASTIC_PASSWORD:-elastic}
    KIBANA_PASSWORD=${KIBANA_PASSWORD:-elastic}
    STACK_VERSION=${STACK_VERSION:-8.17.2}
    CLUSTER_NAME=${CLUSTER_NAME:-elk-cluster}
    LICENSE=${LICENSE:-basic}
    ES_PORT=${ES_PORT:-9200}
    KIBANA_PORT=${KIBANA_PORT:-5601}
    LOGSTASH_PASSWORD=${LOGSTASH_PASSWORD:-elastic}

    echo "Using default values for ELK Stack:"
    echo "ELASTIC_PASSWORD: $ELASTIC_PASSWORD"
    echo "KIBANA_PASSWORD: $KIBANA_PASSWORD"
    echo "STACK_VERSION: $STACK_VERSION"
    echo "CLUSTER_NAME: $CLUSTER_NAME"
    echo "LICENSE: $LICENSE"
    echo "ES_PORT: $ES_PORT"
    echo "KIBANA_PORT: $KIBANA_PORT"
    echo "LOGSTASH_PASSWORD: $LOGSTASH_PASSWORD"

    # Generate encryption key
    ENCRYPTION_KEY=$(openssl rand -base64 32)
    echo "Generated encryption key: $ENCRYPTION_KEY"

    # Create base directories first
    mkdir -p ./elasticsearch-volume
    mkdir -p ./kibana-volume
    mkdir -p ./logstash-volume

    # Create subdirectories
    mkdir -p ./elasticsearch-volume/data
    mkdir -p ./elasticsearch-volume/config
    mkdir -p ./kibana-volume/data
    mkdir -p ./kibana-volume/config
    mkdir -p ./logstash-volume/data
    mkdir -p ./logstash-volume/config
    mkdir -p ./logstash-volume/certs

    # Set permissions for each directory individually
    chmod 775 ./elasticsearch-volume
    chmod 775 ./elasticsearch-volume/data
    chmod 775 ./elasticsearch-volume/config
    chmod 775 ./kibana-volume
    chmod 775 ./kibana-volume/data
    chmod 775 ./kibana-volume/config
    chmod 775 ./logstash-volume
    chmod 775 ./logstash-volume/data
    chmod 775 ./logstash-volume/config
    chmod 775 ./logstash-volume/certs

    # Update Logstash configuration
    sed -i '' "s/password => \"elastic\"/password => \"${LOGSTASH_PASSWORD}\"/" ./logstash.conf

    # Start initial Docker Compose for setup
    echo "Starting initial setup for ELK Stack..."
    docker compose -p elk --env-file .env up -d setup es01 kibana logstash

    # Wait for containers to be healthy
    echo "Waiting for containers to be healthy..."
    for i in {1..90}; do
        echo -n "."
        sleep 1
    done
    echo " Containers are healthy! ✅"

    # Copy files from containers to volumes
    echo "Copying configuration files to volumes..."
    docker cp elk-setup-container:/usr/share/elasticsearch/config/certs ./elasticsearch-volume/config/
    docker cp elk-setup-container:/usr/share/elasticsearch/data ./elasticsearch-volume/data/
    docker cp kibana:/usr/share/kibana/data ./kibana-volume/data/
    docker cp kibana:/usr/share/kibana/config ./kibana-volume/config/
    docker cp logstash:/usr/share/logstash/data ./logstash-volume/data/
    docker cp logstash:/usr/share/logstash/config ./logstash-volume/config/
    docker cp logstash:/usr/share/logstash/certs ./logstash-volume/certs/

    # Set permissions for copied files
    chmod 775 ./elasticsearch-volume/config/certs
    chmod 775 ./elasticsearch-volume/data
    chmod 775 ./kibana-volume/data
    chmod 775 ./kibana-volume/config
    chmod 775 ./logstash-volume/data
    chmod 775 ./logstash-volume/config
    chmod 775 ./logstash-volume/certs

    # Stop and remove containers
    echo "Stopping initial setup containers..."
    docker compose -p elk --env-file .env down -v

    # Start the final containers
    echo "Starting final ELK Stack containers..."
    docker compose -p elk --env-file .env up -d es01 kibana logstash
}

# Main script
echo -e "\033[1;33mWelcome to the DevOps Forge Setup Script!\033[0m"

# Create all necessary configuration files
create_config_files

# Create combined .env file
cat <<EOL > .env
# Prometheus config
PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml

# Grafana credentials
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin

# Image versions
PROMETHEUS_IMAGE_VERSION=v3.2.0
NODE_EXPORTER_IMAGE_VERSION=v1.8.2
GRAFANA_IMAGE_VERSION=11.5.2-ubuntu

# ELK Stack configuration
ELASTIC_PASSWORD=elastic
KIBANA_PASSWORD=elastic
STACK_VERSION=8.17.2
CLUSTER_NAME=elk-cluster
LICENSE=basic
ES_PORT=9200
KIBANA_PORT=5601
LOGSTASH_PASSWORD=elastic

# Memory limits
ES_MEM_LIMIT=4294967296
KB_MEM_LIMIT=1073741824
LS_MEM_LIMIT=1073741824

# Encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)
EOL

echo "Please choose what you want to install:"
echo "1) Prometheus + Grafana + Node Exporter"
echo "2) ELK Stack"
echo "3) Both"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        setup_prometheus_grafana
        ;;
    2)
        setup_elk_stack
        ;;
    3)
        setup_prometheus_grafana
        setup_elk_stack
        ;;
    *)
        echo "Invalid choice. Please run the script again and select 1, 2, or 3."
        exit 1
        ;;
esac

echo -e "\033[1;32mSetup completed successfully! 🎉\033[0m"
echo "For more information, visit:"
echo -e "\033[1;36mGitHub: https://github.com/yusufkaya01\033[0m"
echo -e "\033[1;36mLinkedIn: https://www.linkedin.com/in/yusufkayatr96\033[0m"
