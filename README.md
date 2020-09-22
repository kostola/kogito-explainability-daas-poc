# Kogito Explainability DaaS PoC

The purpose of this repo is to simplify the execution of the _Explainability Service_ together with a _Kogito Service_ running a DMN model for local tests for the DaaS PoC.

## How to use this repo

### Step 1: initialize submodules

This repo contains [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules). In order to fully checkout all the files, you can either:

1. clone the repo the first time this way
```
git clone --recurse-submodules https://github.com/kostola/kogito-explainability-daas-poc.git
```

2. initialize the modules later if you didn't read step #1
```
git submodule update --init --recursive
```

### Step 2: build Docker image for Explainability Service

The Docker image is built directly by Maven in the `package` phase (thanks to [jib](https://github.com/GoogleContainerTools/jib)).

The only prerequisite is having Maven configured with JDK 11 or later.

From the root of the repo, move into the correct directory

```
cd kogito-apps/explainability/explainability-service-rest-daas
```

and run the build

```
mvn clean package -DskipTests -DskipITs
```

### Step 3: build Docker image for Kogito Service

It works the same way as step #2, just in a different subfolder.

From the root of the repo, move into the correct directory

```
cd kogito-examples/dmn-quarkus-example
```

and run the build

```
mvn clean package -DskipTests -DskipITs
```

### Step 4: run docker-compose

Start the containers via docker compose

```
docker-compose up -d
```

The Kogito service is exported to port 8080 of your local machine and the Explainability service to port 8081.

### Step 5: make a test call with cURL

This is a example test call: 

```
curl --location --request POST 'http://localhost:8081/explanations/saliencies' \
--header 'Content-Type: application/json' \
--data-raw '{
    "serviceUrl": "http://kogito-service:8080",
    "modelIdentifier": {
        "resourceType": "dmn",
        "resourceId": "https://github.com/kiegroup/drools/kie-dmn/_A4BCA8B8-CF08-433F-93B2-A2598F19ECFF:Traffic Violation"
    },
    "inputs": {
        "Driver": {
            "Age": 25,
            "Points": 13
        },
        "Violation": {
            "Type": "speed",
            "Actual Speed": 115,
            "Speed Limit": 100
        }
    },
    "outputs": {
        "Fine": {
            "Points": 3,
            "Amount": 500
        },
        "Should the driver be suspended?": "No"
    }
}'
```

If everything works, you should see something similar (probably with different scores) to:

```
{
    "status": "SUCCEEDED",
    "saliencies": [
        {
            "outcomeName": "Fine",
            "featureImportance": [
                {
                    "featureName": "Type",
                    "featureScore": 0.07272604748976075
                },
                {
                    "featureName": "Speed Limit",
                    "featureScore": 0.040955145655707785
                },
                {
                    "featureName": "Actual Speed",
                    "featureScore": 0.07335776416694295
                },
                {
                    "featureName": "Points",
                    "featureScore": -0.09325430824263395
                },
                {
                    "featureName": "Age",
                    "featureScore": -0.09268062092702467
                }
            ]
        },
        {
            "outcomeName": "Should the driver be suspended?",
            "featureImportance": [
                {
                    "featureName": "Type",
                    "featureScore": 0.06817012475818496
                },
                {
                    "featureName": "Speed Limit",
                    "featureScore": -0.014886147059177093
                },
                {
                    "featureName": "Actual Speed",
                    "featureScore": 0.06874381207379421
                },
                {
                    "featureName": "Points",
                    "featureScore": -0.08152813590868102
                },
                {
                    "featureName": "Age",
                    "featureScore": -0.07307396759196835
                }
            ]
        }
    ]
}
```