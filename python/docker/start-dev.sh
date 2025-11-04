#!/bin/bash

# Development startup script for Media Metadata Service

echo "🚀 Starting Media Metadata Service Development Environment"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose not found. Please install docker-compose."
    exit 1
fi

echo "📦 Building and starting services..."
docker-compose up --build -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
echo "🔍 Checking service health..."

# Check API health
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ API service is healthy (http://localhost:8000)"
else
    echo "⚠️  API service may still be starting up"
fi

# Check UI
if curl -s http://localhost:3000 > /dev/null; then
    echo "✅ UI service is healthy (http://localhost:3000)"
else
    echo "⚠️  UI service may still be starting up"
fi

echo ""
echo "🎉 Services started successfully!"
echo ""
echo "📊 Access points:"
echo "   • Web UI:           http://localhost:3000"
echo "   • API:              http://localhost:8000"
echo "   • API Docs:         http://localhost:8000/docs"
echo "   • System Status:    http://localhost:8000/system/status"
echo ""
echo "🛠️  Development tools (with --profile debug):"
echo "   • Redis Commander:  http://localhost:8081"
echo "   • Mongo Express:    http://localhost:8082"
echo ""
echo "📝 Useful commands:"
echo "   • View logs:        docker-compose logs -f"
echo "   • Stop services:    docker-compose down"
echo "   • Restart:          docker-compose restart"
echo ""
echo "🔧 To start with debug tools: docker-compose --profile debug up -d"