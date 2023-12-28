# Scoop Bucket Template

[![Tests](https://github.com/nithinphilips/scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/nithinphilips/scoop-bucket/actions/workflows/ci.yml) [![Excavator](https://github.com/nithinphilips/scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/nithinphilips/scoop-bucket/actions/workflows/excavator.yml)

Nithin's personal [Scoop](https://scoop.sh) bucket.

## Applications

* [birt](https://eclipse-birt.github.io/birt-website) - With BIRT you can create data visualizations, dashboards and reports
* [cv4pve-cli](https://github.com/Corsinvest/cv4pve-cli) - Cli for Proxmox VE (Command Line Interfaces)
* [fname](https://github.com/Splode/fname) - Find and replace text in source files
* [odel](https://github.com/nithinphilips/odel) - A tool to upload file to TRIRIGA using Data Integrator.
* [qsv](https://github.com/jqnatividad/qsv) - qsv is a command line program for indexing, slicing, analyzing, splitting, enriching, validating & joining CSV files.
* [ruplacer](https://github.com/your-tools/ruplacer) - Find and replace text in source files
* [sauce](https://github.com/DanCardin/sauce) - A tool to help manage context/project specific shell-things like environment variables.

## How do I install these manifests?

After manifests have been committed and pushed, run the following:

```pwsh
scoop bucket add scoop-bucket https://github.com/nithinphilips/scoop-bucket
scoop install scoop-bucket/<manifestname>
```

## How do I contribute new manifests?

To make a new manifest contribution, please read the [Contributing
Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)
and [App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
wiki page.

