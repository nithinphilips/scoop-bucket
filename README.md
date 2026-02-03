# Nithin's Scoop Bucket

[![Tests](https://github.com/nithinphilips/scoop-bucket/actions/workflows/ci.yml/badge.svg)](https://github.com/nithinphilips/scoop-bucket/actions/workflows/ci.yml) [![Excavator](https://github.com/nithinphilips/scoop-bucket/actions/workflows/excavator.yml/badge.svg)](https://github.com/nithinphilips/scoop-bucket/actions/workflows/excavator.yml)

Nithin's personal [Scoop](https://scoop.sh) bucket.

## Applications

* [act_runner](https://gitea.com/gitea/act_runner) - A runner for Gitea based on act.
* [birt](https://eclipse-birt.github.io/birt-website) - With BIRT you can create data visualizations, dashboards and reports
* [cb_thunderlink](https://github.com/CamielBouchier/cb_thunderlink) - CB Thunderlink allows you to create direct link to thunderbird emails
* [cilium-cli](https://cilium.io) - CLI to install, manage & troubleshoot Kubernetes clusters running Cilium
* [countryfetch](https://github.com/nik-rev/countryfetch) - A Command-line tool similar to Neofetch for obtaining information about your country
* [cv4pve-cli](https://github.com/Corsinvest/cv4pve-cli) - Cli for Proxmox VE (Command Line Interfaces)
* [dyff](https://github.com/homeport/dyff) - A diff tool for YAML files, and sometimes JSON
* [envfetch](https://github.com/ankddev/envfetch) - Lightweight cross-platform CLI tool for working with environment variables.
* [excalidraw-converter](https://github.com/sindrel/excalidraw-converter) - A command line tool for porting Excalidraw diagrams to Gliffy and draw.io.
* [filebrowser-upload](https://github.com/spotdemo4/filebrowser-upload) - CLI utility for uploading to filebrowser
* [fname](https://github.com/Splode/fname) - Find and replace text in source files
* [fnox](https://fnox.jdx.dev) - encrypted/remote secret manager
* [gfold](https://crates.io/crates/gfold) - CLI tool to help keep track of your Git repositories, written in Rust
* [komotray](https://github.com/joshprk/komotray) - Simple and lightweight tray icon that shows the current workspace for the Komorebi window manager.
* [kroki-cli](https://github.com/yuzutech/kroki-cli) - A Kroki CLI
* [mdq](https://github.com/yshavit/mdq) - like jq but for Markdown: find specific elements in a md doc
* [mergiraf](https://mergiraf.org/) - A syntax-aware git merge driver for a growing collection of programming languages and file formats.
* [odel](https://github.com/nithinphilips/odel) - A tool to upload file to TRIRIGA using Data Integrator.
* [podlet](https://crates.io/crates/podlet) - Generate Podman Quadlet files from a Podman command, compose file, or existing object
* [qsv](https://github.com/jqnatividad/qsv) - qsv is a command line program for indexing, slicing, analyzing, splitting, enriching, validating & joining CSV files.
* [rover](https://github.com/im2nguyen/rover) - Interactive Terraform visualization. State and configuration explorer.
* [run-hidden](https://github.com/stax76/run-hidden) - run-hidden runs Windows console apps like PowerShell with hidden console window.
* [ruplacer](https://github.com/your-tools/ruplacer) - Find and replace text in source files
* [sauce](https://github.com/DanCardin/sauce) - A tool to help manage context/project specific shell-things like environment variables.
* [sequin](https://github.com/charmbracelet/sequin) - Human-readable ANSI sequences
* [sqruff](https://playground.quary.dev/?secondary=Format) - Fast SQL formatter/linter
* [tidy-viewer](https://github.com/alexhallam/tv) - Tidy Viewer is a cross-platform CLI csv pretty printer that uses column styling to maximize viewer enjoyment.
* [vcvarsall](https://github.com/nathan818fr/vcvars-bash) - Bash script to execute vcvarsall.bat and get environment variables for use in Bash
* [websocat](https://github.com/vi/websocat) - Command-line client for WebSockets, like netcat (or curl) for ws:// with advanced socat-like functions
* [WindowsSpyBlocker](https://crazymax.dev/WindowsSpyBlocker/) - Block spying and tracking on Windows
* [woodpecker-agent](https://woodpecker-ci.org) - Woodpecker is a simple, yet powerful CI/CD engine with great extensibility.
* [woodpecker-cli](https://woodpecker-ci.org) - Woodpecker is a simple, yet powerful CI/CD engine with great extensibility.
* [woodpecker-server](https://woodpecker-ci.org) - Woodpecker is a simple, yet powerful CI/CD engine with great extensibility.
* [yaml-diff](https://github.com/sters/yaml-diff) - Make a diff between 2 yaml files.
* [yamlfmt](https://github.com/google/yamlfmt) - An extensible command line tool or library to format yaml files.
* [yapi](https://yapi.run) - The API client that lives in your terminal (and your git repo).

## How do I install these manifests?

After manifests have been committed and pushed, run the following:

```pwsh
scoop bucket add scoop-bucket https://github.com/nithinphilips/scoop-bucket
scoop install scoop-bucket/<manifestname>
```

## How do I create new manifests?

If it's a GitHub hosted app, use `bin/github2scoop.ps1`

If it's a Gitea hosted app, use `bin/gitea2scoop.ps1`

In PowerShell terminal, run `Get-Help bin/github2scoop.ps1` or `Get-Help bin/gitea2scoop.ps1` for usage.

For others, please read the [Contributing
Guide](https://github.com/ScoopInstaller/.github/blob/main/.github/CONTRIBUTING.md)
and [App Manifests](https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests)
wiki page.


## How do I update the list of applications?

The [Applications](#applications) list above can be auto-generated.

Run `./make-apps-list.py` to generate the list for the manifest JSON files.

