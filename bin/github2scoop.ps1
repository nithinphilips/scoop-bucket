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
   PSCompression: Install-Module PSCompression -Scope CurrentUser

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
PS> ./bin/github2scoop.ps1 -assetfilter 'woodpecker-agent*' -name woodpecker-agent -bin "woodpecker-agent.exe" woodpecker-ci/woodpecker

This repo has multiple project assets. Only include assets that start with 'woodpecker-agent'

Also override the manifest name and set the bin file name.
.EXAMPLE
PS> ./bin/github2scoop.ps1 -Bin yamlfmt.exe google/yamlfmt

Create a manifest and set a bin value
.EXAMPLE
PS> ./bin/github2scoop.ps1 vi/websocat

Create a manifest.
#>

[CmdletBinding()]
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


$scoopHome = scoop prefix scoop

. "$scoopHome\lib\core.ps1"
. "$scoopHome\lib\download.ps1"
. "$scoopHome\lib\install.ps1"

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
        $binProperty = $null
    }
}

$version = $githubRepo.latestRelease.tagName -replace("[^\d\.]", "")

$scoopManifest= [ordered]@{
    "version" = $version;
    "description" = $githubRepo.description;
    "homepage" = $homePageUrl;
    "license" = "MIT";
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
            Write-Verbose "Skip $($release.url) because $assetFilter did not match"
            continue
         }
    }

    if (($release.url -imatch "linux") `
        -or ($release.url -imatch "freebsd") `
        -or ($release.url -imatch "netbsd") `
        -or ($release.url -imatch "openbsd") `
        -or ($release.url -imatch "darwin") `
        -or ($release.url -imatch "apple") `
        -or ($release.url -ilike "*.txt") `
        -or ($release.url -ilike "*.json") `
        -or ($release.url -ilike "*.rpm") `
        -or ($release.url -ilike "*.deb") `
        -or ($release.url -ilike "*.sha256") `
        -or ($release.url -ilike "*.pem") `
        -or ($release.url -ilike "*.sig") `
        -or ($release.url -ilike "*.apk") `
        -or ($release.url -ilike "*.vsix") `
        -or ($release.url -ilike "*source.tar*") `
        -or ($release.url -ilike "*source.zip*")
    ) {
        Write-Host "Skip $($release.url)"
        continue
    }

    if (($release.url -imatch "amd64") -or ($release.url -imatch "x86_64") -or ($release.browser_download_url -imatch "x64")) {
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

    Invoke-CachedDownload -app $manifestName -version $version -url $release.url -to $null -cookies $null -use_cache:$true
    $tempFile = cache_path $manifestName $version $release.url
    $hash = (Get-FileHash -Path $tempFile -Algorithm "SHA256").Hash.ToLower()

    # TODO: Do different things for .zip, .exe, .tar, .tar.gz and unknown
    if ($release.url -imatch '.zip$') {
        $zipEntries = Get-ZipEntry $tempFile -Include *.exe
        if ($zipEntries) {
            $exeName = $zipEntries[0].RelativePath
            if ($exeName -and !$scoopManifest["bin"]) {
                # Stray comma forces the nested array
                $scoopManifest["bin"] = @(, @( $exeName, $manifestName ) )

                # TODO: Do this for $scoopManifest["bin"] entries, not just when we know the exe name
                if ($exeName.contains($version)) {
                    $exeVarName = $exeName.replace($version, '$version')
                    $scoopManifest["autoupdate"]["bin"] = @(, @( $exeVarName, $manifestName ) )
                }
            }
        }
    } elseif ($release.url -imatch '.exe$') {
        $exeName = Split-Path -Leaf $release.url
        $scoopManifest["bin"] = @(, @( $exeName, $manifestName ) )
        $exeVarName = $exeName.replace($version, '$version')
        $scoopManifest["autoupdate"]["bin"] = @(, @( $exeVarName, $manifestName ) )
    } else {
        Write-Warning "The file format is not supported and cannot set the bin property automatically."
    }

    $scoopManifest["architecture"][$arch] = @{
        "url" = $release.url;
        "hash" = $hash;
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

#Write-Host "Populating hashes:"
#& ./bin/checkhashes.ps1 -App $manifestName

Get-Content $manifestFile | jq

Write-Host "Edit $manifestFile and populate the following poperties:"
Write-Host " * bin: check if this was detected correctly"
Write-Host " * if the architecture detection was not correct, edit the `"architecture`" property and run"
Write-Host ""
Write-Host "      pwsh ../bin/checkhashes.ps1 -App $manifestName -Update"
Write-Host ""
Write-Host "   to update the hashes again"
Write-Host ""
Write-Host "For more details, see https://github.com/ScoopInstaller/Scoop/wiki/App-Manifests"

$fullManifestPath = (Resolve-Path $manifestFile)

Write-Host "Test installation by running:"
Write-Host ""
Write-Host "    scoop install '$fullManifestPath'"
Write-Host ""
Write-Host "Then uninstall so you install from the bucket properly:"
Write-Host ""
Write-Host "    scoop uninstall $manifestName"

