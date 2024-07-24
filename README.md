# HNG DevOps Internship Stage Five Submission

## Project Overview

This repository contains my submission for the HNG Internship stage 5a task. 

It contains a bash script called  devopsfetch that collects and displays system information, including active ports, user logins, Nginx configurations, Docker images, and container statuses.

## Features

- **Retrieve active ports and their detailed information.**
- **List all Docker images and containers and their detailed information.**
- **Display all Nginx domains and their ports along with their detailed information.**
- **List all users and their detailed information.**
- **Display activities within a specified time range.**

## Instructions

1. To effectively run this script, you need to install jq. (jq is a lightweight and flexible command-line JSON processor for JSON data):
   ```bash
    For Linux: sudo apt-get install jq 
    For mac: brew install jq

2. Make the script executable
   ```bash
   chmod +x script.sh

3. Then run the script in a bash terminal.
   ```bash
   ./script.sh
