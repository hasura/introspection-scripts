## Manual source introspection for Hasura GraphQL Engine

These scripts simulate the source introspection that is carried out during HGE startup.

Two kinds of sources are introspected. Results are saved in the `results/` directory.

### Postgres

CLI arguments are as for `psql`, which this wraps around. E.g.:
```
PGPASSWORD=postgres ./introspect_postgres.sh  -h 127.0.0.1 -p 25432 postgres -U postgres
```
Or using a connection string:
```
./introspect_postgres.sh postgresql://other@localhost/otherdb?connect_timeout=10&application_name=myapp
```

Only one DB is supported. If several DBs are used, make sure to rename the files in `results/postgres/` so that they don't get overwritten by subsequent invocations of `introspect_postgres.sh`.

### Remote schema

CLI arguments are for `curl`, which this wraps around. However, make sure that the first CLI argument is the URL!

```
./introspect_remote.sh https://lenient-koi-58.hasura.app/v1/graphql -H "x-hasura-admin-secret: adminsecret123"
```
This would write results to `results/remotes/lenient-koi-58.hasura.app.json`.
