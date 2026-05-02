Tenancy Design
===============

Chosen model: schema-per-tenant (single RDS instance, schema per tenant)

Why schema-per-tenant

- Security: schemas provide logical isolation while reducing operational cost compared to db-per-tenant. Sensitive data is still isolated at the DB engine level.
- Operational: easier global queries (when required), and simpler to manage backups/maintenance.

Tenant context handling

1. Authentication: users authenticate via central auth (not included here). On successful login the service issues a JWT containing a `tenant_id` claim.
2. Service receives requests with JWT in `Authorization: Bearer <token>` header.
3. Middleware extracts `tenant_id` and attaches it to request context; all DB queries include a schema or `WHERE tenant_id = :tenant_id`.

Preventing cross-tenant leakage

- Application-level enforcement: Every repository method requires tenant context and sets the schema search_path or binds `tenant_id` to queries. Query builders and ORM layers are wrapped to ensure tenant constraint injection.
- DB permissions: Create database roles with limited privileges per-schema where possible.
- Infrastructure-level isolation: network segmentation, IAM S3 prefixes for tenant-specific blobs.

Defense-in-depth

- App-level: strict input validation, parameterized queries, tenancy middleware that fails closed if tenant_id is absent.
- Infra-level: S3 prefixes + IAM policies limit each role to only its prefix; RDS is private and only accessible from service instances; Security Groups restrict access.
- Monitoring & alerts: unusual cross-tenant query patterns trigger alarms.
