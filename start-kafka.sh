#!/bin/bash

# Start Kafka infrastructure using Docker Compose
echo "Starting Kafka infrastructure..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start the services
docker-compose up -d

# Wait for Kafka to be ready
echo "Waiting for Kafka to be ready..."
sleep 30

# Check if Kafka is running
if docker ps | grep -q kafka; then
    echo "✅ Kafka is running on localhost:9092"
    echo "✅ Kafka UI is available at http://localhost:8081"
    echo ""
    echo "To create a test topic, run:"
    echo "docker exec -it kafka kafka-topics --create --topic test-topic --bootstrap-server localhost:9092 --partitions 1 --replication-factor 1"
    echo ""
    echo "To produce test messages, run:"
    echo "docker exec -it kafka kafka-console-producer --topic test-topic --bootstrap-server localhost:9092"
    echo ""
    echo "To stop Kafka, run: docker-compose down"
else
    echo "❌ Failed to start Kafka. Check the logs with: docker-compose logs"
    exit 1
fi 