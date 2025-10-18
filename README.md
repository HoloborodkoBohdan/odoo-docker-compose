# Odoo 19 Fast Development Environment

Quick Docker-based setup for Odoo 19 development with PostgreSQL 16 and PgAdmin.

## Quick Start

Clone this repo and set up permissions:
```bash
git clone --single-branch --branch 19.0 https://github.com/HoloborodkoBohdan/odoo-docker-compose odoo19
cd odoo19
sudo chmod -R 777 addons etc
```

### Environment Setup

Copy the example environment file and configure it:
```bash
cp .env.example .env
```

Edit `.env` and set your credentials:
- `POSTGRES_PASSWORD` - Database password
- `PGADMIN_DEFAULT_EMAIL` - PgAdmin login email
- `PGADMIN_DEFAULT_PASSWORD` - PgAdmin login password

**Note:** Default ports are configured for fast setup:
- Odoo: `8019`
- PostgreSQL: `6543`
- PgAdmin: `5050`

### Start Development Environment

```bash
docker-compose up -d
```

Access Odoo at: **http://localhost:8019**

To view logs:
```bash
docker-compose logs -f odoo
```

## Custom Addons

Place your custom addons in the **addons/** folder. They will be automatically mounted to `/mnt/extra-addons` in the container.

The development environment includes `--dev=reload` for automatic module reloading.

## Configuration

### Odoo Configuration

Edit **etc/odoo.conf** to customize Odoo settings.

Master Password default: `admin0doo` (change this in production!)

Full configuration guide: [Odoo Deployment Documentation](https://www.odoo.com/documentation/19.0/administration/on_premise/deploy.html)

Log file location: **etc/odoo-server.log**

### Port Configuration

To change ports, edit the `.env` file:
- `ODOO_PORT` - Odoo web interface port
- `POSTGRES_PORT` - PostgreSQL external port
- `PGADMIN_PORT` - PgAdmin web interface port

## PgAdmin Access

PgAdmin is available at: **http://localhost:5050**

Login with credentials from your `.env` file (`PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD`).

### Add Odoo Database Server in PgAdmin:

1. Right-click "Servers" → "Register" → "Server"
2. Configure connection:
   - **Name:** Odoo DB (any name)
   - **Host name/address:** `db`
   - **Port:** `5432`
   - **Username:** Value from `POSTGRES_USER` in `.env`
   - **Password:** Value from `POSTGRES_PASSWORD` in `.env`

![PgAdmin Configuration](screenshots/pgadmin-conf.png)

If you don't need PgAdmin, comment it out in `docker-compose.yml`.

## Docker Services

The environment includes:
- **odoo:19** - Odoo application server
- **postgres:16** - PostgreSQL database
- **pgadmin4** - Database management UI

## Development Workflow

1. Add custom modules to `addons/` folder
2. Restart Odoo container: `docker-compose restart odoo`
3. Update app list in Odoo (Apps → Update Apps List)
4. Install/upgrade your module

## Stopping the Environment

```bash
docker-compose down
```

To remove all data (fresh start):
```bash
docker-compose down -v
sudo rm -rf postgresql/
```

## Troubleshooting

**Permission issues:**
```bash
sudo chmod -R 777 addons etc
```

**Reset database:**
```bash
docker-compose down -v
sudo rm -rf postgresql/
docker-compose up -d
```

**View container logs:**
```bash
docker-compose logs -f
```

## Version Support

This repository supports multiple Odoo versions via branches:
- 19.0 (current)
- 19.0
- 17.0
- 16.0
- 15.0
- 14.0

Switch versions: `git checkout <version>`
