#!/bin/bash
# One-time setup script for Material Map with FastAPI backend

set -e  # Exit on error

echo "🚀 Material Map - FastAPI Backend Setup"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Backend setup
echo -e "${BLUE}Step 1: Setting up FastAPI Backend...${NC}"

if [ ! -d "backend" ]; then
    echo "Error: backend directory not found!"
    exit 1
fi

cd backend

# Create virtual environment
echo -e "${YELLOW}Creating Python virtual environment...${NC}"
if ! python -m venv venv; then
    echo "Error: Could not create virtual environment. Make sure Python 3.10+ is installed."
    exit 1
fi

# Activate virtual environment
echo -e "${YELLOW}Activating virtual environment...${NC}"
source venv/bin/activate 2>/dev/null || . venv/Scripts/activate 2>/dev/null || true

# Install dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"
if ! pip install -r requirements.txt; then
    echo "Error: Could not install dependencies"
    exit 1
fi

# Create .env file
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Please edit .env file with your configuration${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

echo -e "${GREEN}✓ Backend setup complete!${NC}"
echo ""

# Step 2: Flutter setup
echo -e "${BLUE}Step 2: Setting up Flutter App...${NC}"
cd ..

if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found!"
    exit 1
fi

echo -e "${YELLOW}Running flutter pub get...${NC}"
if ! flutter pub get; then
    echo "Error: Could not install Flutter dependencies. Make sure Flutter is installed."
    exit 1
fi

echo -e "${GREEN}✓ Flutter setup complete!${NC}"
echo ""

# Step 3: Instructions
echo -e "${GREEN}=========================================="
echo "✅ Setup Complete!"
echo "=========================================${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo ""
echo "1. Edit backend configuration:"
echo "   nano backend/.env"
echo ""
echo "2. Update Flutter API URL (if needed):"
echo "   nano lib/core/constants/api_config.dart"
echo ""
echo "3. Start the backend (in one terminal):"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   python main.py"
echo ""
echo "4. Run the Flutter app (in another terminal):"
echo "   flutter run"
echo ""
echo -e "${YELLOW}API Documentation will be at: http://localhost:8000/docs${NC}"
echo ""
echo "Test credentials:"
echo "  Email: test@example.com"
echo "  Password: password123"
echo ""
