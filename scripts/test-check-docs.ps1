# Regression fixtures for the documentation checker; the real docs are never modified.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$checker = Join-Path $PSScriptRoot 'check-docs.ps1'
$fixtureName = 'vault-doc-check-' + [Guid]::NewGuid().ToString('N')
$tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$fixtureRoot = [IO.Path]::GetFullPath((Join-Path $tempRoot $fixtureName))
$docs = Join-Path $fixtureRoot 'docs'
[void](New-Item -ItemType Directory -Path $docs)
$utf8 = [Text.UTF8Encoding]::new($false)
$page = @'
---
title: Fixture
description: Documentation checker regression fixture
tags: [fixture]
updated: 2026-10-01
---
# Fixture

## Связанные темы

## Duplicate

## Duplicate
'@
$summary = "# Contents`n`n* [Fixture](README.md)`n"
$passed = 0

function Invoke-Fixture([string]$name, [string]$body, [string]$toc, [string]$expectedError = '') {
    [IO.File]::WriteAllText((Join-Path $docs 'README.md'), $body + "`n", $utf8)
    [IO.File]::WriteAllText((Join-Path $docs 'SUMMARY.md'), $toc, $utf8)
    $output = & pwsh -NoProfile -File $checker -RepositoryRoot $fixtureRoot 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    if ($expectedError) {
        if ($exitCode -eq 0 -or -not $output.Contains($expectedError)) {
            throw "Fixture '$name' should reject '$expectedError'; got: $output"
        }
    } elseif ($exitCode -ne 0) {
        throw "Fixture '$name' should pass; got: $output"
    }
    $script:passed++
}

try {
    [IO.File]::WriteAllText((Join-Path $docs 'asset.svg'), '<svg xmlns="http://www.w3.org/2000/svg"/>', $utf8)
    Invoke-Fixture 'valid links and anchors' ($page + "`n[Topic](#связанные-темы)`n[Duplicate](#duplicate-1)`n![Asset][pic]`n[pic]: asset.svg`n") $summary
    Invoke-Fixture 'missing anchor' ($page + "`n[Missing](#absent)`n") $summary 'missing Markdown anchor'
    Invoke-Fixture 'missing reference asset' ($page + "`n![Asset][pic]`n[pic]: missing.svg`n") $summary 'missing local target'
    Invoke-Fixture 'undefined reference' ($page + "`n[Topic][undefined]`n") $summary 'undefined reference link'
    Invoke-Fixture 'invalid calendar date' ($page.Replace('2026-10-01', '2026-02-30')) $summary 'no valid updated date'
    Invoke-Fixture 'field outside frontmatter' ($page.Replace('title: Fixture', '') + "`ntitle: Body is not metadata`n") $summary 'no title'
    Invoke-Fixture 'duplicate metadata key' ($page.Replace('title: Fixture', "title: Fixture`ntitle: Other")) $summary 'duplicate key'
    Invoke-Fixture 'empty tags' ($page.Replace('tags: [fixture]', 'tags: []')) $summary 'nonempty tags list'
    Invoke-Fixture 'normalized navigation duplicate' $page ($summary + "* [Again](./README.md)`n") 'duplicate target'
    Invoke-Fixture 'orphan page' $page "# Contents`n" 'not present in SUMMARY'
    Invoke-Fixture 'missing navigation target' $page ($summary + "* [Missing](absent.md)`n") 'missing page'
    Invoke-Fixture 'missing HTML asset' ($page + "`n<img src='missing.svg'>`n") $summary 'missing local target'
    Invoke-Fixture 'code is not a link' ($page + "`n~~~text`n[Fake](missing.md)`n~~~`n") $summary
    [void](New-Item -ItemType Directory -Path (Join-Path $docs 'assets'))
    Invoke-Fixture 'asset folder needs no content index' $page $summary
    Write-Host "Checker regression fixtures passed: $passed."
} finally {
    # Only remove the unique directory created by this test, after verifying its parent.
    if ([IO.Path]::GetDirectoryName($fixtureRoot) -ne $tempRoot.TrimEnd('\', '/') -or
        [IO.Path]::GetFileName($fixtureRoot) -ne $fixtureName) {
        throw 'Refusing to remove an unexpected fixture path'
    }
    Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
}
