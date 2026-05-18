# KeepUp Backend

Rails 8 API for the KeepUp sports communication platform. Multi-tenant, district-scoped, with demo mode and Gemma-powered content moderation.

## Requirements

- Ruby 3.2.2 (managed via rbenv or rvm)
- PostgreSQL 14+
- Redis (for SolidQueue and SolidCache)

## Local setup

```bash
gem install bundler
bundle install

bin/rails db:create db:migrate db:seed
```

The seed file builds the full Hajos School District demo scenario — three schools, sports, seasons, users, and roles. It is safe to re-run (`find_or_create_by!` throughout).

Start the server:

```bash
bin/rails server   # runs on localhost:3000
```

## Environment

Rails uses its encrypted credentials file (`config/credentials.yml.enc`) for secrets. The master key lives in `config/master.key` (gitignored — get it from the team).

For local S3 uploads, set AWS credentials with access to `hajos-keepup-dev`:

```bash
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_REGION=us-east-2
export S3_BUCKET=hajos-keepup-dev
```

For Gemma content moderation, run the FastAPI service separately and point to it:

```bash
export GEMMA_SERVICE_URL=http://localhost:8000
```

If `GEMMA_SERVICE_URL` is not set or the service is down, moderation jobs fail silently — messages still deliver.

## Tests

```bash
bundle exec rspec
```

## Deployment

Pushing to `dev`, `staging`, or `main` triggers GitHub Actions, which builds a `linux/amd64` Docker image, pushes it to ECR, registers a new ECS task definition revision pointing to that image, and deploys it to the corresponding Fargate cluster. The entrypoint runs `db:prepare` on startup, so migrations are applied automatically.

---

## Design decisions — do not change without understanding the consequences

### COPPA / FERPA compliance
Never pass student message content to the FastAPI moderation service in a way that could be logged or retained. The FastAPI service receives message text for real-time scoring only. Rails never forwards raw student message content to any external system. This is load-bearing for school district sales and legal compliance.

### Pundit for all authorization
Every controller action that touches a record must go through a Pundit policy. Do not add `skip_before_action :require_authentication` or call `.find` without a subsequent policy check. `ApplicationPolicy` denies everything by default — permissions must be explicitly granted.

### District routing via header, not Rails-side subdomain parsing
The frontend reads the hostname, extracts the district slug, and sends it as `X-District-Subdomain`. Rails reads `request.headers["X-District-Subdomain"]` in `current_district`. Do not try to parse the `Host` header in Rails — the ALB sits in front and the app sees a single domain regardless of what subdomain the user hit.

### Season is the core scoping unit
Channels, DMs, and memberships belong to a `Season`, not directly to a `Sport`. A sport has many seasons (fall 2024, spring 2025, etc.). Queries that filter by sport must join through `seasons`. Do not add `sport_id` foreign keys to message or channel tables.

### S3 key structure
Keys are namespaced by district subdomain: `{district_subdomain}/{school_slug}/...`. Every district's assets are isolated without needing separate buckets. `S3KeyBuilder` owns all key generation — do not construct S3 keys inline in controllers.

### Demo mode
Demo sessions are issued as JWTs with a `"demo": true` claim. In `authenticate_token`, demo JWTs skip the `jti` check (no per-session revocation). Real user sessions use `jti` for revocation. Do not conflate the two paths.

### Production server: Puma on port 3000, no Thruster
The Dockerfile runs `./bin/rails server -b 0.0.0.0 -p 3000`. There is no Thruster or reverse proxy in the container — the ALB handles TLS termination. Do not add Thruster back; it conflicts with the ECS health check on `/up`.

### Docker images must target linux/amd64
The ECS cluster runs on x86. Images built on Apple Silicon without `--platform linux/amd64` will fail in ECS with `exec format error`. CI handles this automatically. For any manual image push:

```bash
docker buildx build --platform linux/amd64 -t <uri> --push .
```

### SolidQueue guard in AccessLog
Background jobs in `AccessLog#trigger_anomaly_analysis` are wrapped in a rescue for `SolidQueue::Job::EnqueueError` and `ActiveRecord::StatementInvalid`. Do not remove this — if queue tables are not yet migrated in an environment, the rescue prevents a request failure.
