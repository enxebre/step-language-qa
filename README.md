# Language-qa

A step for running language checks over a modified text files.

## Dependencies

This build-step assumes the next tools are installed:
* curl
* unzip 
* java
* npm

The buildstep will fail if any of them is missing. Please install those in your box wercker.yml

You can do this as follows -

```yaml
box: wercker/python
no-response-timeout: 15
build:
  steps:
    - install-packages:
        packages: curl unzip java npm
    - capgemini/language-qa:
        lang: en
        lang_country: en-GB
```

## License

The MIT License (MIT)
