# Nithin's Scoop Bucket

[![Tests](https://github.com/nithinphilips/scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/nithinphilips/scoop-bucket/actions/workflows/ci.yml) [![Excavator](https://github.com/nithinphilips/scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/nithinphilips/scoop-bucket/actions/workflows/excavator.yml)

Nithin's personal [Scoop](https://scoop.sh) bucket.

## Applications

* [birt](https://eclipse-birt.github.io/birt-website) - With BIRT you can create data visualizations, dashboards and reports
* [cb_thunderlink](https://github.com/CamielBouchier/cb_thunderlink) - CB Thunderlink allows you to create direct link to thunderbird emails
* [cv4pve-cli](https://github.com/Corsinvest/cv4pve-cli) - Cli for Proxmox VE (Command Line Interfaces)
* [dyff](https://github.com/homeport/dyff) - A diff tool for YAML files, and sometimes JSON
* [fname](https://github.com/Splode/fname) - Find and replace text in source files
* [gfold](https://crates.io/crates/gfold) - CLI tool to help keep track of your Git repositories, written in Rust
* [odel](https://github.com/nithinphilips/odel) - A tool to upload file to TRIRIGA using Data Integrator.
* [qsv](https://github.com/jqnatividad/qsv) - qsv is a command line program for indexing, slicing, analyzing, splitting, enriching, validating & joining CSV files.
* [ruplacer](https://github.com/your-tools/ruplacer) - Find and replace text in source files
* [sauce](https://github.com/DanCardin/sauce) - A tool to help manage context/project specific shell-things like environment variables.
* [tidy-viewer](https://github.com/alexhallam/tv) - Tidy Viewer is a cross-platform CLI csv pretty printer that uses column styling to maximize viewer enjoyment.
* [websocat](https://github.com/vi/websocat) - Command-line client for WebSockets, like netcat (or curl) for ws:// with advanced socat-like functions
* [woodpecker-agent](https://woodpecker-ci.org) - Woodpecker is a simple, yet powerful CI/CD engine with great extensibility.
* [yaml-diff](https://github.com/sters/yaml-diff) - Make a diff between 2 yaml files.
* [yamlfmt](https://github.com/google/yamlfmt) - An extensible command line tool or library to format yaml files.

## How do I install these manifests?

After manifests have been committed and pushed, run the following:

```pwsh
scoop bucket add scoop-bucket https://github.com/nithinphilips/scoop-bucket
scoop install scoop-bucket/<manifestname>
```

## How do I create new manifests?

If it's a GitHub hosted app, use `bin/github2scoop.ps1`

In PowerShell terminal, run `Get-Help bin/github2scoop.ps1` for usage.

For others, please read the [Contributing
Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)
and [App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
wiki page.


## How do I update the list of applications?

The [Applications](#applications) list above can be auto-generated.

Run `./make-apps-list.py` to generate the list for the manifest JSON files.

