#!/usr/bin/env pwsh

<#
.SYNOPSIS
Rapidly create a Scoop app manifest for an app hosted on GitHub.
.DESCRIPTION
Rapidly create a Scoop app manifest for an app hosted on GitHub.

Requirements:
   gh: scoop install main/gh
   jq: scoop install main/jq
   PowerShell 7.x: winget install Microsoft.Powershell

.PARAMETER repo
A GitHub Repository name. Use <owner>/<repo> format.
.PARAMETER name
The name of the manifest. If omitted, the github repo name is used.

The generated manifest will be saved to bucket/<name>.json
.PARAMETER bin
Set the name of the bin file. Only a String value is supported. If you have a complex setting, edit the JSON.

If this value is omitted and a manifest file exists, the old value is copied to the new file (arrays are supported here)
.PARAMETER assetFilter
Applies a filter to the release assets. The filter is applied to the asset name.

If set only files matching the filter is included.
.PARAMETER force
If the manifest file already exists, force overwriting it.

When forced, bin, post_install, depends and suggests propertied are copied from the old manifest.
.PARAMETER forceCopy
When used along with -force, write the output to a new manifest file. The manifest will be saved to bucket/<name>.new.json

Helpful when testing.

.EXAMPLE
./bin/github2scoop.ps1 -assetfilter 'woodpecker-agent*' -name woodpecker-agent -bin "woodpecker-agent.exe" woodpecker-ci/woodpecker

This repo has multiple project assets. Only include assets that start with 'woodpecker-agent'

Also override the manifest name and set the bin file name.
.EXAMPLE
./bin/github2scoop.ps1 -Bin yamlfmt.exe google/yamlfmt

Create a manifest and set a bin value
.EXAMPLE
./bin/github2scoop.ps1 vi/websocat

Create a manifest. Bin value will be "<fill-it-in>"
#>

param(
    [Parameter(Mandatory=$true)]
    [String]$repo,
    [String]$name,
    [String]$bin,
    [String]$assetFilter,
    [Switch]$force=$false,
    [Switch]$forceCopy=$false
)




$githubRepo=ConvertFrom-Json $(gh repo view --json name,description,url,homepageUrl,licenseInfo,latestRelease $repo)


if (!$name) {
    $manifestName = $githubRepo.name
} else {
    $manifestName = $name
}

$manifestFile = "bucket/$($manifestName).json"

if (Test-Path $manifestFile) {
    Write-Warning "$manifestFile already exists"
    if(!$force) {
        exit 1
    } else {
        # Read the json and get bin
        $oldManifest = ((Get-Content $manifestFile) | ConvertFrom-Json -Depth 10)
        if (!$bin) {
            $binProperty = ($oldManifest.bin)
            Write-Warning "Using `"bin`" property from existing manifest: $($binProperty)"
        }
        $postInstallProperty = ($oldManifest.post_install)
        $dependsProperty = ($oldManifest.depends)
        $suggestsProperty = ($oldManifest.suggests)
    }

    if($forceCopy) {
        $manifestFile = "$($manifestName).new.json"
        Write-Warning "-Copy switch set. Change output file to $manifestFile"
    }
}

$githubRelease=ConvertFrom-Json $(gh release view --json assets,author,body,createdAt,tagName,url --repo $repo $githubRepo.latestRelease.tagName)

$homePageUrl = $githubRepo.homepageUrl

if (!$homePageUrl) {
    $homePageUrl = $githubRepo.url
}

if (!$binProperty) {
    if($bin){
        $binProperty = $bin
    } else {
        $binProperty = "<fill-it-in>"
    }
}

$version = $githubRepo.latestRelease.tagName -replace("[^\d\.]", "")

$scoopManifest= [ordered]@{
    "version" = $version;
    "description" = $githubRepo.description;
    "homepage" = $homePageUrl;
    "license" = "MIT license";
    "architecture" = [ordered]@{
    };
    "bin" = $binProperty;
    "checkver" = [ordered]@{
        "github" = $githubRepo.url;
    };
    "autoupdate" = [ordered]@{
        "architecture" = [ordered]@{

        };
    };
}

if($postInstallProperty) {
    $scoopManifest["post_install"] = $postInstallProperty
}

if($dependsProperty) {
    $scoopManifest["depends"] = $dependsProperty
}

if($suggestsProperty) {
    $scoopManifest["suggests"] = $suggestsProperty
}


$index=0

ForEach($release in $githubRelease.assets){
    $arch = "arch-$index"

    if($assetFilter) {
         if (!($release.name -ilike $assetFilter)) {
            Write-Host "Skip $($release.url) because $assetFilter did not match"
            continue
         }
    }

    if (($release.url -imatch "linux") `
        -or ($release.url -imatch "freebsd") `
        -or ($release.url -imatch "darwin") `
        -or ($release.url -imatch "apple") `
        -or ($release.url -ilike "*.txt") `
        -or ($release.url -ilike "*.rpm") `
        -or ($release.url -ilike "*.deb") `
        -or ($release.url -ilike "*.sha256")
    ) {
        Write-Host "Skip $($release.url)"
        continue
    }

    if (($release.url -imatch "amd64") -or ($release.url -imatch "x86_64")) {
        $arch = "64bit"
    } elseif (($release.url -imatch "arm64") -or ($release.url -imatch "aarch64")) {
        $arch = "arm64"
    } elseif (($release.url -imatch "i686") -or ($release.url -imatch "x86") -or ($release.url -imatch "386")) {
        $arch = "32bit"
    }

    if ($scoopManifest["architecture"].Contains($arch) ){
        Write-Warning "Multiple binaries found for $arch. Renamed to $index-$arch. Edit manually and fix."
        $arch = "$index-$arch"
    }

    $scoopManifest["architecture"][$arch] = @{
        "url" = $release.url;
        "hash" = "<not-set>";
    };

    $scoopManifest["autoupdate"]["architecture"][$arch] = @{
        "url" = $release.url.Replace($version, "`$version");
    };
    $index = $index + 1
}

#ConvertTo-Json $scoopManifest | Write-Host
$manifestJson = ConvertTo-Json -Depth 10 $scoopManifest
$manifestJson | Out-File $manifestFile
Write-Host "Manifest written to $manifestFile"

Write-Host "Populating hashes:"
& ./bin/checkhashes.ps1 -App $manifestName -Update

Get-Content $manifestFile | jq

Write-Host "Edit $manifestFile and populate the following poperties:"
Write-Host " * bin"
Write-Host ""
Write-Host "   If the app download just an exe named anything and you want the command you want is 'app':"
Write-Host "       `"bin`": `"app`""
Write-Host "   If the app download is an exe named 'app-windows-amd64.exe' and the command you want is 'app':"
Write-Host "       `"bin`": [ [`"app-windows-amd64.exe`", `"app`"] ]"
Write-Host "   If the app download just an archive with the exe in the root of the zip:"
Write-Host "       `"bin`": `"app.exe`""
Write-Host "   If the app download is an archive and the binary is in a sub directory 'app/app-windows-amd64.exe' and the command you want is 'app':"
Write-Host "       `"bin`": [ [`"app/app-windows-amd64.exe`", `"app`"] ]"
Write-Host ""
Write-Host "   The second part should never have the .exe extension"
Write-Host ""
Write-Host " * if the architecture detection was not correct, edit the `"architecture`" property and run"
Write-Host ""
Write-Host "      pwsh ../bin/checkhashes.ps1 -App $manifestName -Update"
Write-Host ""
Write-Host "   to update the hashes again"
Write-Host ""
Write-Host "For more details, see https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests"

$fullManifestPath = (Resolve-Path $manifestFile)

Write-Host "Test installation by running:"
Write-Host " scoop install $fullManifestPath"
Write-Host "Then uninstall so you install from the bucket properly:"
Write-Host " scoop uninstall $manifestName"
