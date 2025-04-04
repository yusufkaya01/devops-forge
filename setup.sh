#!/bin/bash

# Function to display the Prometheus/Grafana banner
show_prometheus_banner() {
    echo -e "\033[1;31m
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⣠⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⠻⠿⡇⠀⠀⠀⠀⢸⠿⠟⠓⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⣶⣦⡀⢀⣤⣤⡀⢀⣴⣶⣿⣷⣦⣄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⡇⢸⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠘⠋⣉⡉⠙⠛⢿⣿⡇⢸⣿⣿⡇⢸⣿⡿⠛⠋⢉⣉⠙⠃⠀⠀⠀⠀
⠀⠀⢀⣤⣾⡛⠛⠛⠻⢷⣤⡙⠃⢸⣿⣿⡇⠘⢋⣤⣾⡟⠛⠛⠛⠷⣤⡀⠀⠀
⠀⢀⣾⣿⣿⡇⠀⠀⠀⠀⠙⣷⠀⠘⠛⠛⠃⠀⣾⣿⣿⣿⠀⠀⠀⠀⠈⢷⡀⠀
⠀⢸⡇⠈⠉⠀⠀⠀⠀⠀⠀⢸⡆⢰⣿⣿⡆⢰⡇⠀⠉⠁⠀⠀⠀⠀⠀⢸⡇⠀
⠀⠸⣧⠀⠀⠀⠀⠀⠀⠀⢀⡾⠀⠀⠉⠉⠀⠀⢷⡀⠀⠀⠀⠀⠀⠀⠀⣼⠇⠀
⠀⠀⠙⢷⣄⣀⠀⠀⣀⣤⡾⠁⠀⠀⠀⠀⠀⠀⠈⢷⣤⣀⠀⠀⣀⣠⡾⠋⠀⠀
⠀⠀⠀⠀⠉⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠉⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\033[0m

\033[1;35m
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
    echo -e "\e[34m
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⠤⢾⣞⣿⣿⣿⣶
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠔⠚⠉⢁⣤⣶⣾⣿⣟⠻⢇⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠒⠋⠉⠀⠀⠀⣠⣶⣿⣿⡿⢋⡴⠟⣾⡾⠉
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡴⠚⠁⠀⠀⠀⠀⣠⣴⣾⣿⢟⡿⢋⡴⠛⣠⢾⠏⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠚⠁⠀⠀⠀⠀⢠⣾⣿⠿⡟⢋⠔⢁⣴⠟⢁⡴⣱⠋⠀⠀⠀
⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡶⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⠀⠀⣤⢶⣶⣾⡟⢠⠋⢠⠏⡰⢻⠋⡠⢋⡞⠁⠀⠀⠀⠀
⡏⢧⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡿⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⢀⣰⣶⣿⣷⣇⣾⣿⢿⣤⠃⢠⢏⡞⣡⢃⣞⣡⠋⠀⠀⠀⠀⠀⠀
⡇⠈⠈⠳⢦⡀⠀⠀⢀⣤⣠⣴⠗⠛⠀⢠⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀⣴⠋⠁⣠⣿⣿⣿⢟⣽⡿⢃⡴⢃⠞⣰⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀
⢻⡄⠀⠀⠸⢿⣿⡶⣾⡍⠉⠁⠀⠀⣠⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠋⠀⠀⠀⣸⠁⠀⢠⣾⣿⣯⣕⣿⣯⠖⢉⡴⢋⣼⣽⣵⣯⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠈⢿⣆⡀⠀⢺⣿⡇⠻⣿⣄⣀⣤⡾⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠎⠀⠀⠀⢠⣼⡇⠀⠀⠀⠻⣯⢛⡵⠚⢁⡴⠊⣠⣾⣿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠙⠿⣶⣾⣿⣇⠀⢿⣿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣾⠁⠀⠀⠀⢠⣿⣿⡇⠀⠀⠀⢡⣿⠏⣀⠔⢋⡠⣪⣿⣿⣿⠟⠻⠇⡼⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠉⢻⡄⠈⢳⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⠇⠀⠀⣀⣰⣿⣿⣿⠀⠀⠀⠀⣆⣿⡏⢁⣴⣯⡾⠋⣿⣿⡁⠀⠀⠀⠳⡆⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⡀⠀⢲⣾⣿⠓⠲⢤⣤⣤⠤⠔⣲⠟⠛⠋⠁⢀⣴⣴⡿⣿⣽⣿⣿⣿⣿⡁⠀⠀⠀⢰⣻⡿⠟⠁⠀⠀⠀⠀⠈⣧⠀⠀⠀⣼⠇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣦⣄⡙⠁⠀⠐⠿⠿⠀⠀⠀⠀⠀⠐⠿⠿⢾⣻⣴⣿⣿⡿⠿⠻⣿⡿⠀⠀⠀⠀⣾⡟⠀⠀⠀⠀⠀⠀⠀⠀⠘⣇⠀⣼⡿⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣿⣶⣾⣿⣶⣶⣦⣤⣤⣴⣖⣶⣾⡿⠿⠛⢉⣀⣤⣴⣶⣿⡇⠀⠀⠀⢰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⢰⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠻⠿⢿⣻⣿⣿⣿⠛⣭⣴⣒⣒⣚⣛⣯⡭⠽⠛⠋⣿⡇⠀⠀⢠⡞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡿⢠⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⠉⠀⠀⠀  ⠀⠀⢻⣷⠀⢀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣞⣀⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀   ⠸⣿⣀⣮⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  ⢿⣿⣻⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  ⠘⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  ⠘⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
\e[0m"

    echo -e "
\033[38;5;214m _____ _     _  __  ____       _               
| ____| |   | |/ / / ___|  ___| |_ _   _ _ __  
|  _| | |   | ' /  \___ \ / _ \ __| | | | '_ \ 
| |___| |___| . \   ___) |  __/ |_| |_| | |_) |
|_____|_____|_|\_\ |____/ \___|\__|\__,_| .__/ 
                                        |_|    \033[0m"
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

    # Generate .env file for Prometheus and Grafana
    cat <<EOL > .env.prometheus
# Prometheus config
PROMETHEUS_CONFIG_PATH=/etc/prometheus/prometheus.yml

# Grafana credentials
GF_SECURITY_ADMIN_USER=$GF_SECURITY_ADMIN_USER
GF_SECURITY_ADMIN_PASSWORD=$GF_SECURITY_ADMIN_PASSWORD

# Image versions
PROMETHEUS_IMAGE_VERSION=$PROMETHEUS_IMAGE_VERSION
NODE_EXPORTER_IMAGE_VERSION=$NODE_EXPORTER_IMAGE_VERSION
GRAFANA_IMAGE_VERSION=$GRAFANA_IMAGE_VERSION
EOL

    # Create directories for volumes
    mkdir -p ./grafana-volume ./prometheus-volume
    chmod 775 ./grafana-volume ./prometheus-volume

    # Start Docker Compose
    docker compose -f docker-compose.prometheus.yml up -d
}

# Function to setup ELK Stack
setup_elk_stack() {
    show_elk_banner

    echo "Please provide the following values for the .env file:"
    echo "------------------------------------------------------------------"
    read -p "Enter ELASTIC_PASSWORD (at least 6 characters): " ELASTIC_PASSWORD
    echo "------------------------------------------------------------------"
    read -p "Enter KIBANA_PASSWORD (at least 6 characters): " KIBANA_PASSWORD
    echo "------------------------------------------------------------------"
    read -p "Enter ENCRYPTION_KEY (random key for encryption or press Enter to generate): " ENCRYPTION_KEY
    echo "------------------------------------------------------------------"
    read -p "Enter STACK_VERSION (e.g., 8.17.2): " STACK_VERSION
    echo "------------------------------------------------------------------"
    read -p "Enter CLUSTER_NAME (e.g., my-cluster): " CLUSTER_NAME
    echo "------------------------------------------------------------------"
    read -p "Enter LICENSE type ('basic' or 'trial', default is 'basic'): " LICENSE
    echo "------------------------------------------------------------------"
    LICENSE=${LICENSE:-basic}
    read -p "Enter ES_PORT (default 9200): " ES_PORT
    echo "------------------------------------------------------------------"
    ES_PORT=${ES_PORT:-9200}
    read -p "Enter KIBANA_PORT (default 5601): " KIBANA_PORT
    echo "------------------------------------------------------------------"
    KIBANA_PORT=${KIBANA_PORT:-5601}
    echo "------------------------------------------------------------------"
    read -p "Enter LOGSTASH_PASSWORD (at least 6 characters): " LOGSTASH_PASSWORD
    echo "------------------------------------------------------------------"

    # Generate encryption key if not provided
    if [ -z "$ENCRYPTION_KEY" ]; then
        ENCRYPTION_KEY=$(openssl rand -base64 32)
        echo "Generated encryption key: $ENCRYPTION_KEY"
    fi

    # Generate .env file for ELK Stack
    cat <<EOL > .env.elk
# Project namespace
#COMPOSE_PROJECT_NAME=myproject

# Password for the 'elastic' user
ELASTIC_PASSWORD=${ELASTIC_PASSWORD}

# Password for the 'kibana_system' user
KIBANA_PASSWORD=${KIBANA_PASSWORD}

# Version of Elastic products
STACK_VERSION=${STACK_VERSION}

# Set the cluster name
CLUSTER_NAME=${CLUSTER_NAME}

# Set to 'basic' or 'trial'
LICENSE=${LICENSE}

# Port to expose Elasticsearch HTTP API to the host
ES_PORT=${ES_PORT}

# Port to expose Kibana to the host
KIBANA_PORT=${KIBANA_PORT}

# Memory limits
ES_MEM_LIMIT=4294967296
KB_MEM_LIMIT=1073741824
LS_MEM_LIMIT=1073741824

# Encryption key
ENCRYPTION_KEY=${ENCRYPTION_KEY}
EOL

    # Create directories for volumes
    mkdir -p ./elasticsearch-volume ./kibana-volume ./logstash-volume
    chmod 775 -R ./elasticsearch-volume ./kibana-volume ./logstash-volume

    # Update Logstash configuration
    sed -i "s/password => \"<changeme>\"/password => \"${LOGSTASH_PASSWORD}\"/" ./logstash.conf

    # Start Docker Compose
    docker compose -f docker-compose.elk.yml up -d

    # Wait for containers to be healthy
    echo "Waiting for containers to be healthy..."
    for i in {1..90}; do
        echo -n "."
        sleep 1
    done
    echo " Containers are healthy! ✅"

    # Copy files from containers to volumes
    docker cp elasticsearch:/usr/share/elasticsearch/data ./elasticsearch-volume/
    docker cp elasticsearch:/usr/share/elasticsearch/config ./elasticsearch-volume/
    docker cp kibana:/usr/share/kibana/data ./kibana-volume/
    docker cp kibana:/usr/share/kibana/config ./kibana-volume/
    docker cp logstash:/usr/share/logstash/data ./logstash-volume/
    docker cp logstash:/usr/share/logstash/config ./logstash-volume/
    docker cp logstash:/usr/share/logstash/certs ./logstash-volume/

    # Set permissions for copied files
    chmod 775 -R ./elasticsearch-volume ./kibana-volume ./logstash-volume

    # Stop and remove containers
    docker compose -f docker-compose.elk.yml down -v

    # Replace docker-compose.yml with the one from ./after-setup
    mv ./docker-compose.elk.yml ./compose.old
    cp ./after-setup/docker-compose.yml ./docker-compose.elk.yml

    # Restart containers
    docker compose -f docker-compose.elk.yml up -d
}

# Main script
echo -e "\033[1;33mWelcome to the DevOps Forge Setup Script!\033[0m"
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
