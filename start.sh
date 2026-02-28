#!/bin/bash
set -e

echo "🚀 Starting Material Map Backend..."

# Change to backend directory
cd backend

# Create database tables if they don't exist
echo "📦 Initializing database..."
python -c "
from main import app, db
with app.app_context():
    try:
        db.create_all()
        print('✅ Database tables created/verified')
    except Exception as e:
        print(f'⚠️  Database init warning: {e}')
" || echo "⚠️  Database initialization skipped"

# Start the Flask app with gunicorn
echo "🌐 Starting gunicorn server..."
exec gunicorn --bind 0.0.0.0:$PORT --workers 4 --timeout 60 --access-logfile - --error-logfile - main:app

