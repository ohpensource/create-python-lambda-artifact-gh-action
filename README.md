# create-python-lambda-artifact-gh-action

Provides a github action to pack and upload python serverless projects.

- [Code of conduct](#code-of-conduct)
- [Github action](#github-action)

## Code of conduct

Go crazy on the pull requests :) ! The only requirements are:

> - Use _conventional-commits_.
> - Include _jira-tickets_ in your commits.
> - Create/Update the documentation of the use case you are creating, improving or fixing. **[Boy scout](https://biratkirat.medium.com/step-8-the-boy-scout-rule-robert-c-martin-uncle-bob-9ac839778385) rules apply**. That means, for example, if you fix an already existing workflow, please include the necessary documentation to help everybody. The rule of thumb is: _leave the place (just a little bit)better than when you came_.

## Github action

This repository contains 2 actions. One action packs a python project and the other one creates a layer artifact from a 'requirements.txt' file. Here you have an example on how to use them:

```yaml
build-modules:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    - uses: ohpensource/create-python-lambda-artifact-gh-action/upload-artifact@v0.1.0
      with:
        region: "eu-west-1"
        access-key: "540gj..."
        secret-key: "5rgij..."
        account-id: "my-account-id"
        role-name: "my-role-name"
        bucket-name: "my-bucket-name"
        service-name: "my-service-name"
        version: "1.2.3"
        module-path: "src/modules"
    - uses: ohpensource/create-python-lambda-artifact-gh-action/upload-layer@v0.1.0
      with:
        region: "eu-west-1"
        access-key: "540gj..."
        secret-key: "5rgij..."
        account-id: "my-account-id"
        role-name: "my-role-name"
        bucket-name: "my-bucket-name"
        service-name: "my-service-name"
        layer-name: "my-layer-name"
        version: "1.2.3"
        requirements-file: "src/requirements.txt"
```
