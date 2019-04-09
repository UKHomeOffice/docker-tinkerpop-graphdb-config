# docker-tinkerpop-graphdb-config

WORK IN PROGRESS

Config for [docker-tinkerpop-graphdb](https://github.com/UKHomeOffice/docker-tinkerpop-graphdb) docker image for tinkerpop gremlin.

This repo will mount a config directory that will enable graphdb to talk to DynamoDB with Lucene as the search engine.

It will load a test schema defined in `kube/conf/graph-schema.json` and expects a file (`kube/awscreds.txt`) to be present with the following content:

```
AWS_ACCESS_KEY_ID=<key-id>
AWS_SECRET_ACCESS_KEY=<secret-key>
```

where `<key-id>` and `<secret-key>` are placeholder for the aws key id and its associated secret key

## Kubernetes

To deploy the resources in kubernetes:

```shell
kustomize build | kubectl apply -f -
```

## Port description

* 8182: graphdb tinkerpop gremlin groovy
* 3001: healthcheck
* 5006: remote java debugging

## Testing

```shell
docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -v `pwd`/kube/conf:/opt/graphdb/conf -p5006:5006 -p3001:3001 -p8182:8182 docker-tinkerpop-graphdb-image-tag
```

```shell
# add a vertex
curl -XPOST  http://localhost:8182 -d '{"gremlin": "g.addV(\"P.person\").property(\"P.person.id\",\"foo\")"}'
```

```shell
# retrieve the test vertex
curl -XPOST  http://localhost:8182 -d '{"gremlin": "g.V().has(\"P.person.id\",eq(\"foo\"))"}'
```

```shell
# probes
curl -XPOST  http://localhost:3001/healthcheck/liveliness
curl -XPOST  http://localhost:3001/healthcheck/readiness
```
