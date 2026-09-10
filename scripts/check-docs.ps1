[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$docsRoot = Join-Path $repositoryRoot 'docs'
$summaryPath = Join-Path $docsRoot 'SUMMARY.md'
$errors = [Collections.Generic.List[string]]::new()

function Add-CheckError([string]$message) {
    $errors.Add($message)
}

$markdownFiles = Get-ChildItem -LiteralPath $docsRoot -Recurse -File -Filter '*.md'

foreach ($file in $markdownFiles) {
    $relativePath = [IO.Path]::GetRelativePath($repositoryRoot, $file.FullName).Replace('\', '/')
    $content = Get-Content -Raw -LiteralPath $file.FullName

    if ([string]::IsNullOrWhiteSpace($content)) {
        Add-CheckError "$relativePath is empty"
        continue
    }

    if ($content -match '!?\[\[[^\]]+\]\]') {
        Add-CheckError "$relativePath contains an Obsidian wiki-link"
    }
    if ($content -match '(?m)(?<!\w)\^[A-Za-z0-9_-]+\s*$') {
        Add-CheckError "$relativePath contains an Obsidian block ID"
    }
    if ($content.StartsWith('---')) {
        if ($content -notmatch '(?s)\A---\r?\n.+?\r?\n---\r?\n') {
            Add-CheckError "$relativePath has malformed frontmatter delimiters"
        }
        if ($content -notmatch '(?m)^title:\s*.+$') {
            Add-CheckError "$relativePath frontmatter has no title"
        }
    }

    # Code such as `table[0](value)` is not a Markdown link.
    $contentWithoutCode = [regex]::Replace($content, '(?s)```.*?```', '')
    $contentWithoutCode = [regex]::Replace($contentWithoutCode, '`[^`\r\n]+`', '')
    $matches = [regex]::Matches($contentWithoutCode, '!?(?<!\!)\[[^\]]*\]\(([^)]+)\)')
    foreach ($match in $matches) {
        $destination = $match.Groups[1].Value.Trim()
        if ($destination.StartsWith('<') -and $destination.EndsWith('>')) {
            $destination = $destination.Substring(1, $destination.Length - 2)
        }
        $destination = ($destination -split '#', 2)[0]
        $destination = ($destination -split '\s+"', 2)[0]
        if ([string]::IsNullOrWhiteSpace($destination) -or
            $destination -match '^(https?:|mailto:|tel:|data:)') {
            continue
        }

        try {
            $decoded = [Uri]::UnescapeDataString($destination).Replace('/', [IO.Path]::DirectorySeparatorChar)
            $resolved = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $decoded))
            if (-not (Test-Path -LiteralPath $resolved)) {
                Add-CheckError "$relativePath -> missing local target: $destination"
            }
        } catch {
            Add-CheckError "$relativePath -> invalid local target: $destination"
        }
    }
}

$summary = Get-Content -Raw -LiteralPath $summaryPath
$summaryTargets = [regex]::Matches($summary, '\[[^\]]+\]\(([^)]+\.md)\)') |
    ForEach-Object { $_.Groups[1].Value }
$duplicates = $summaryTargets | Group-Object | Where-Object Count -gt 1
foreach ($duplicate in $duplicates) {
    Add-CheckError "SUMMARY.md contains duplicate target: $($duplicate.Name)"
}
foreach ($target in $summaryTargets) {
    $resolved = [IO.Path]::GetFullPath((Join-Path $docsRoot $target.Replace('/', [IO.Path]::DirectorySeparatorChar)))
    if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        Add-CheckError "SUMMARY.md -> missing page: $target"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Documentation checks passed: $($markdownFiles.Count) Markdown files, $($summaryTargets.Count) SUMMARY entries."
