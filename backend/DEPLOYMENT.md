# WMS Backend - Vercel Deployment Guide

This guide walks you through deploying the WMS Backend to Vercel step by step.

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **GitHub Repository**: Your backend code should be in a GitHub repository
3. **Turso Database**: Production database is already configured
4. **Environment Variables**: Production values are ready

## Step 1: Prepare Your Project

### 1.1 Create Vercel Configuration

Create `vercel.json` in your backend root directory:

```json
{
  "version": 2,
  "name": "wms-backend",
  "builds": [
    {
      "src": "dist/index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/dist/index.js"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  },
  "functions": {
    "dist/index.js": {
      "maxDuration": 30
    }
  }
}
```

### 1.2 Update package.json Scripts

Add Vercel-specific build script:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "vercel-build": "npm run build",
    "dev": "tsx watch src/index.ts"
  }
}
```

### 1.3 Create .vercelignore

Create `.vercelignore` file:

```
node_modules
.env*
src
tests
*.test.ts
*.test.js
coverage
.nyc_output
.DS_Store
```

## Step 2: Database Migration Setup

### 2.1 Update Database Migration Script

Ensure `src/config/migrate.ts` supports production:

```typescript
import { migrate } from 'drizzle-orm/libsql/migrator';
import { db } from './database';

async function runMigrations() {
  console.log('Running database migrations...');
  
  try {
    await migrate(db, { 
      migrationsFolder: './drizzle',
    });
    console.log('✅ Database migrations completed successfully');
  } catch (error) {
    console.error('❌ Database migration failed:', error);
    process.exit(1);
  }
}

runMigrations();
```

### 2.2 Add Migration to Build Process

Update `package.json` to include migration:

```json
{
  "scripts": {
    "vercel-build": "npm run build && npm run db:migrate:prod"
  }
}
```

## Step 3: Deploy to Vercel

### Method 1: Deploy via Vercel CLI (Recommended)

1. **Install Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Navigate to Backend Directory**:
   ```bash
   cd /path/to/your/backend
   ```

4. **Deploy**:
   ```bash
   vercel
   ```
   
   Follow the prompts:
   - Link to existing project? **No**
   - Project name: **wms-backend**
   - Directory: **./backend** (or current directory)
   - Override settings? **No**

### Method 2: Deploy via Vercel Dashboard

1. **Connect GitHub Repository**:
   - Go to [vercel.com/dashboard](https://vercel.com/dashboard)
   - Click "New Project"
   - Import your GitHub repository

2. **Configure Project**:
   - **Framework Preset**: Other
   - **Root Directory**: `backend` (if in monorepo)
   - **Build Command**: `npm run vercel-build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm install`

## Step 4: Configure Environment Variables

### 4.1 Add Environment Variables in Vercel Dashboard

Go to your project settings and add these environment variables:

**Database Configuration:**
```
DATABASE_URL=libsql://wmsproprod-budisantosodev.aws-ap-northeast-1.turso.io
DATABASE_AUTH_TOKEN=eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3NTMxMDU4NjIsImlkIjoiOTA4Yjc0MTgtNTI0NC00M2YxLWE3NDktYjNlMzFlMjZkZDE2IiwicmlkIjoiNzgyMjZjY2ItMDBlYi00MGIwLWJmMzItOGRhZTNhNWI5YTc0In0.YAyqTihi943mBCb9qok_SdlQbTRbUX--L4plFo9I1wdcA1CbYbWBQgHTKXVSHmz5SSkTOzCmAzak36Pg2X4JCg
```

**JWT Configuration:**
```
JWT_SECRET=F2X31xTS7muhzevHfKasoZFRRU9twUUp
JWT_REFRESH_SECRET=bI1v30WjyRLYW8DbOUkShg9UCocJlRNz
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
```

**Server Configuration:**
```
NODE_ENV=production
PORT=3000
CORS_ORIGIN=*
```

**Authentication:**
```
BASIC_AUTH_USERNAME=devel_master
BASIC_AUTH_PASSWORD=gIQcbkWjVpCzcS41JW2u3thQK7lteFRW
```

**Optional:**
```
BARCODE_PREFIX=A
```

### 4.2 Using Vercel CLI for Environment Variables

```bash
# Add environment variables via CLI
vercel env add DATABASE_URL
vercel env add DATABASE_AUTH_TOKEN
vercel env add JWT_SECRET
vercel env add JWT_REFRESH_SECRET
vercel env add BASIC_AUTH_USERNAME
vercel env add BASIC_AUTH_PASSWORD
```

## Step 5: Verify Deployment

### 5.1 Check Deployment Status

1. **Build Logs**: Check build logs in Vercel dashboard
2. **Function Logs**: Monitor runtime logs
3. **Health Check**: Test the health endpoint

### 5.2 Test API Endpoints

Test your deployed API:

```bash
# Health check
curl https://your-app.vercel.app/health

# API endpoints (with authentication)
curl https://your-app.vercel.app/api/v1/auth/dev/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password"}'
```

## Step 6: Domain Configuration (Optional)

### 6.1 Add Custom Domain

1. Go to Project Settings → Domains
2. Add your custom domain
3. Configure DNS records as instructed
4. Update CORS_ORIGIN environment variable

### 6.2 SSL Certificate

Vercel automatically provides SSL certificates for all domains.

## Step 7: Monitoring and Maintenance

### 7.1 Monitor Performance

- **Function Metrics**: Monitor in Vercel dashboard
- **Database Performance**: Monitor Turso dashboard
- **Error Tracking**: Check function logs

### 7.2 Scaling Considerations

- **Function Limits**: Vercel Pro has higher limits
- **Database Connections**: Turso handles connection pooling
- **Request Timeout**: Current max duration is 30s

## Troubleshooting

### Common Issues

1. **Build Failures**:
   - Check TypeScript compilation errors
   - Verify all dependencies are installed
   - Check environment variable references

2. **Runtime Errors**:
   - Verify environment variables are set
   - Check database connectivity
   - Monitor function logs

3. **Database Connection**:
   - Verify DATABASE_URL and DATABASE_AUTH_TOKEN
   - Test connection locally with production env
   - Check Turso database status

### Debug Commands

```bash
# Check build locally
npm run build

# Test production build locally  
NODE_ENV=production node dist/index.js

# Run migrations manually
NODE_ENV=production npm run db:migrate:prod

# Check environment variables
vercel env ls
```

## Security Considerations

1. **Environment Variables**: Never commit `.env.production` to version control
2. **JWT Secrets**: Use strong, unique secrets
3. **CORS Configuration**: Restrict origins in production
4. **Authentication**: Secure basic auth credentials
5. **Database Access**: Use read-only tokens where possible

## Performance Optimization

1. **Cold Starts**: Consider Vercel Pro for faster cold starts
2. **Database Queries**: Optimize database queries and indexes
3. **Caching**: Implement appropriate caching strategies
4. **Monitoring**: Use Vercel Analytics and monitoring tools

## Maintenance

### Regular Tasks

1. **Monitor Logs**: Check for errors and performance issues
2. **Update Dependencies**: Keep packages updated
3. **Database Maintenance**: Monitor database performance
4. **Security Updates**: Apply security patches promptly

### Rollback Procedure

If deployment fails:

1. **Revert via Vercel Dashboard**: Use deployment history
2. **Revert via CLI**:
   ```bash
   vercel rollback [deployment-url]
   ```

## Next Steps

After successful deployment:

1. **Update Mobile App**: Point mobile app to production API
2. **Testing**: Run integration tests against production
3. **Documentation**: Update API documentation with production URLs
4. **Monitoring**: Set up alerts and monitoring
5. **Backup Strategy**: Implement database backup procedures

---

## Quick Reference

**Production URL**: `https://your-app.vercel.app`
**Health Check**: `https://your-app.vercel.app/health`
**API Base**: `https://your-app.vercel.app/api/v1`
**Database**: Turso (libsql://wmsproprod-budisantosodev.aws-ap-northeast-1.turso.io)

**Support**: For issues, check Vercel documentation or contact support.