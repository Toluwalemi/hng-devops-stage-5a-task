#!/bin/bash

# Function to display usage
usage() {
  echo "Hello, Champ🫡!"
  echo "Devopsfetch🔥 is a tool that collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses."
  echo ""
  echo "To effectively use please install jq: sudo apt-get install jq"
  echo "usage: ./devopsfetch [-p | --port] [-d | --docker] [-n | --nginx] [-u | --users] [-t | --time] [-h | --help]"
  echo ""
  echo "These are the commands you can use in various situations:"
  echo ""
  echo "List all active ports and services along with their detailed information"
  echo "  -p, --port                  List all active ports and services."
  echo "  -p <port_number>            Provide detailed information about a specific port."
  echo ""
  echo "List all docker images and containers or detailed images and containers"
  echo "  -d, --docker               List all Docker images and containers."
  echo "  -d <container_name>        Provide detailed information about a specific container."
  echo ""
  echo "List all users and their last login times and a user's detailed information."
  echo "  -u, --users                List all users and their last login time.s"
  echo "  -u <username>              Provide detailed information about a specific user."
  echo ""
  echo "List all Nginx domains and their ports and their detailed information."
  echo "  -n, --nginx                List all nginx domains and their ports."
  echo "  -n <domain>                Provide detailed information about a specific nginx domain."
  echo ""
  echo "Display activities within a specified time range. Date format is yyyy-mm-dd"
  echo "  -t, --time <time_range>             Display activities within a specified time range."
  echo "  -t, --time 2024-07-18 2024-07-22    Display activities from 18th till 22nd of August."
  echo "  -t, --time 2024-07-21               Display all activities that happened on the server on the 21st of August."
  echo ""
  echo "If you are lost, call 911🚨🚨🚨 with:"
  echo "  -h, --help                 Display this help message"
  exit 1
}

# Function to list all Docker images
list_docker_images() {
  echo "Docker Images:"
  docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}"
}

# Function to list all Docker containers
list_docker_containers() {
  echo "Docker Containers:"
  docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.ID}}\t{{.Status}}\t{{.Ports}}"
}

# Function to show detailed information about a specific container
show_container_info() {
  container_name=$1
  echo "Detailed Information for Container: $container_name"
  docker inspect "$container_name" | jq '.[0] | {Name: .Name, ID: .Id, Image: .Config.Image, State: .State, Network: .NetworkSettings.Networks}'
}

# Function to list all users and their last login times
list_users() {
  echo "Users and Last Login Times:"
  lastlog | awk 'NR==1 || $3 != "**Never logged in**"' | column -t
}

# Function to show detailed information about a specific user
show_user_info() {
  username=$1
  echo "Detailed Information for User: $username"
  getent passwd "$username" | awk -F: '{print "Username: " $1 "\nUID: " $3 "\nGID: " $4 "\nHome Directory: " $6 "\nShell: " $7}'
  echo ""
  lastlog -u "$username"
}

# Function to display help message
display_help() {
  usage
}

# Function to display activities within a specified time range
display_time_range_activities() {
  if [[ -n $2 ]]; then
    start_date=$1
    end_date=$2
    echo "Showing activities from $start_date to $end_date"
    last | awk -v start="$start_date" -v end="$end_date" '$4 >= start && $4 <= end'
    echo ""
    journalctl --since="$start_date" --until="$end_date"
  else
    start_date=$1
    echo "Showing activities from $start_date to today"
    last | awk -v start="$start_date" '$4 >= start'
    echo ""
    journalctl --since="$start_date"
  fi
}

# Function to list all active ports and services
list_ports() {
  echo "Active Ports and Services:"
  lsof -i -P -n | grep LISTEN
}

# Function to show detailed information about a specific port
show_port_info() {
  port_number=$1
  echo "Detailed Information for Port: $port_number"
  lsof -i -P -n | grep ":$port_number (LISTEN)"
}


# Function to list all Nginx domains and their ports
list_nginx_domains() {
  echo "Nginx Domains and Ports:"
  grep 'server_name' /etc/nginx/sites-available/* -r | awk '{print $2}'
  echo ""
  grep 'listen' /etc/nginx/sites-available/* -r | awk '{print $2}'
}

# Function to show detailed configuration information about a specific Nginx domain
show_nginx_domain_info() {
  domain=$1
  echo "Detailed Configuration for Domain: $domain"
  grep -r "server_name $domain;" /etc/nginx/sites-available/* | awk -F: '{print $1}' | xargs cat
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq could not be found. Please install jq to run this script."
  exit 1
fi

# Parse command line arguments
if [[ $# -lt 1 ]]; then
  usage
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--docker)
      if [[ -n $2 && $2 != -* ]]; then
        show_container_info "$2"
        shift 2
      else
        list_docker_images
        echo ""
        list_docker_containers
        shift
      fi
      ;;
    -u|--users)
      if [[ -n $2 && $2 != -* ]]; then
        show_user_info "$2"
        shift 2
      else
        list_users
        shift
      fi
      ;;
    -n|--nginx)
      if [[ -n $2 && $2 != -* ]]; then
        show_nginx_domain_info "$2"
        shift 2
      else
        list_nginx_domains
        shift
      fi
      ;;
    -t|--time)
      if [[ -n $2 && $2 != -* ]]; then
        if [[ -n $3 && $3 != -* ]]; then
          display_time_range_activities "$2" "$3"
          shift 3
        else
          display_time_range_activities "$2"
          shift 2
        fi
      else
        usage
      fi
      ;;
    -p|--port)
      if [[ -n $2 && $2 != -* ]]; then
        show_port_info "$2"
        shift 2
      else
        list_ports
        shift
      fi
      ;;
    -h|--help)
      display_help
      ;;
    *)
      usage
      ;;
  esac
done