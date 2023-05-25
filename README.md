## Manual source introspection for Hasura GraphQL Engine

These scripts simulate the source introspection that is carried out during HGE startup.

Two kinds of sources are introspected. Results are saved in the `results/` directory.

### Automatically introspect everything

```
./introspect_all.sh exported_metadata.json
```
