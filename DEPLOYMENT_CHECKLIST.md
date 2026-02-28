# ✅ Render Deployment Checklist

## Before Deploying

- [ ] All code changes are committed to git
- [ ] Run `python3 -c "from backend.main import app; print('✅ Imports OK')"` - should succeed
- [ ] Procfile exists in root directory
- [ ] Procfile content is correct:
  ```
  web: gunicorn --chdir backend --bind 0.0.0.0:$PORT --workers 4 --timeout 60 --access-logfile - --error-logfile - main:app
  ```

## In Render Dashboard

- [ ] Go to Material Map service settings
- [ ] Verify Environment Variables are set:
  - [ ] `DATABASE_URL` (PostgreSQL connection string)
  - [ ] `SECRET_KEY` (any secure string)
  - [ ] `SUPABASE_URL` (if using Supabase)
  - [ ] `SUPABASE_KEY` (if using Supabase)
- [ ] Ensure all required variables are marked as "sync: false" (confidential)

## Deployment

- [ ] Click "Manual Deploy" or push code to trigger auto-deploy
- [ ] Wait for build to complete (2-3 minutes)
- [ ] Check the Logs section for success message

## Post-Deployment Testing

- [ ] Test health endpoint: `curl https://material-map.onrender.com/health`
- [ ] Test API status: `curl https://material-map.onrender.com/api/status`
- [ ] Test products endpoint: `curl https://material-map.onrender.com/api/products`
- [ ] If no data, seed it: `curl -X POST https://material-map.onrender.com/api/seed`

## Frontend Testing

- [ ] Open Flutter app
- [ ] Should see data loading from API
- [ ] No CORS errors in console
- [ ] All screens should display correctly

## Success Indicators

✅ Backend is running on Render
✅ Flutter app receives data from backend
✅ CORS errors are gone
✅ All endpoints respond with correct data

## If Something Goes Wrong

1. Check Render logs for specific error messages
2. Verify DATABASE_URL is set and correct
3. Run health endpoint test locally
4. Review `RENDER_DEPLOYMENT_FIX.md` for troubleshooting
5. Check `BACKEND_DIAGNOSTICS.md` for detailed diagnostics

---

## Git Commands to Deploy

```bash
# 1. Commit changes
cd /Users/sidharth_sk/Desktop/mini/prj/material_map
git add .
git commit -m "Fix Render deployment - CORS and gunicorn issues"
git push

# 2. Then manually deploy in Render dashboard
# OR wait for auto-deploy if webhook is configured
```

---

## Quick Test Commands After Deployment

```bash
# Test health
curl https://material-map.onrender.com/health

# Test API
curl https://material-map.onrender.com/api/products | head -20

# Seed database if needed
curl -X POST https://material-map.onrender.com/api/seed
```
