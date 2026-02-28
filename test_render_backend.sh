#!/bin/bash
# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Material Map - Backend & Database Connection Tester${NC}\n"

# Test 1: Check if Render backend is reachable
echo -e "${BLUE}Test 1: Render Backend Reachability${NC}"
if curl -s -m 5 https://material-map.onrender.com/health > /dev/null; then
    echo -e "${GREEN}✅ Backend is running on Render${NC}"
else
    echo -e "${RED}❌ Cannot reach Render backend${NC}"
    echo "   Make sure backend is deployed and Render service is running"
fi

# Test 2: Check API status
echo -e "\n${BLUE}Test 2: Database Connection Status${NC}"
STATUS_RESPONSE=$(curl -s -m 5 https://material-map.onrender.com/api/status)
DB_TYPE=$(echo $STATUS_RESPONSE | grep -o '"database_type":"[^"]*"' | cut -d'"' -f4)
DB_CONNECTED=$(echo $STATUS_RESPONSE | grep -o '"database_connected":[^,}]*' | cut -d':' -f2)

if [[ "$DB_CONNECTED" == "true" ]]; then
    echo -e "${GREEN}✅ Database is connected (Type: $DB_TYPE)${NC}"
    PRODUCT_COUNT=$(echo $STATUS_RESPONSE | grep -o '"products":[0-9]*' | cut -d':' -f2)
    echo "   Products in database: $PRODUCT_COUNT"
    
    if [[ "$PRODUCT_COUNT" == "0" ]]; then
        echo -e "${YELLOW}⚠️  No products found. You need to seed the database.${NC}"
        echo "   Run: curl -X POST https://material-map.onrender.com/api/seed"
    fi
else
    echo -e "${RED}❌ Database connection failed${NC}"
    echo "   This is the issue - see QUICK_RENDER_SETUP.md for fix"
    ERROR_MSG=$(echo $STATUS_RESPONSE | grep -o '"error":"[^"]*"')
    if [[ -n "$ERROR_MSG" ]]; then
        echo "   Error: $ERROR_MSG"
    fi
fi

# Test 3: Check if products endpoint returns data
echo -e "\n${BLUE}Test 3: Products Endpoint${NC}"
PRODUCTS=$(curl -s -m 5 https://material-map.onrender.com/api/products)
PRODUCT_COUNT=$(echo $PRODUCTS | grep -o '"id"' | wc -l)

if [ "$PRODUCT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Products endpoint returns data ($PRODUCT_COUNT products)${NC}"
else
    echo -e "${YELLOW}⚠️  No products returned${NC}"
    echo "   Either database is empty or connection failed"
fi

# Test 4: Check stores
echo -e "\n${BLUE}Test 4: Stores Endpoint${NC}"
STORES=$(curl -s -m 5 https://material-map.onrender.com/api/stores)
STORE_COUNT=$(echo $STORES | grep -o '"id"' | wc -l)

if [ "$STORE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Stores endpoint returns data ($STORE_COUNT stores)${NC}"
else
    echo -e "${YELLOW}⚠️  No stores returned${NC}"
fi

# Test 5: Check if Render is using correct database type
echo -e "\n${BLUE}Test 5: Database Configuration${NC}"
ENV=$(echo $STATUS_RESPONSE | grep -o '"environment":"[^"]*"' | cut -d'"' -f4)

if [[ "$DB_TYPE" == "SQLite" && "$ENV" == "production" ]]; then
    echo -e "${RED}❌ CRITICAL: Using SQLite in production!${NC}"
    echo "   This means DATABASE_URL is not set in Render"
    echo "   Follow: QUICK_RENDER_SETUP.md"
elif [[ "$DB_TYPE" == "PostgreSQL" ]]; then
    echo -e "${GREEN}✅ Using PostgreSQL (Correct for production)${NC}"
else
    echo -e "${YELLOW}⚠️  Database type: $DB_TYPE${NC}"
fi

# Summary
echo -e "\n${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}Summary:${NC}"
if [[ "$DB_CONNECTED" == "true" && "$DB_TYPE" == "PostgreSQL" && "$PRODUCT_COUNT" -gt 0 ]]; then
    echo -e "${GREEN}✅ All systems operational!${NC}"
    echo "    Your Flutter app should now get data."
else
    echo -e "${YELLOW}⚠️  There are issues to fix${NC}"
    echo "    See QUICK_RENDER_SETUP.md for detailed steps"
fi
echo -e "${BLUE}════════════════════════════════════════${NC}\n"
