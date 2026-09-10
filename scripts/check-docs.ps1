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
    $docsRelativePath = [IO.Path]::GetRelativePath($docsRoot, $file.FullName).Replace('\', '/')
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
    if ($docsRelativePath -ne 'SUMMARY.md' -and -not $content.StartsWith('---')) {
        Add-CheckError "$relativePath has no YAML frontmatter"
    }
    if ($content.StartsWith('---')) {
        if ($content -notmatch '(?s)\A---\r?\n.+?\r?\n---\r?\n') {
            Add-CheckError "$relativePath has malformed frontmatter delimiters"
        }
        if ($content -notmatch '(?m)^title:\s*.+$') {
            Add-CheckError "$relativePath frontmatter has no title"
        }
        if ($content -notmatch '(?m)^description:\s*.+$') {
            Add-CheckError "$relativePath frontmatter has no description"
        }
        if ($content -notmatch '(?m)^tags:\s*(?:\[[^\]]*\])?\s*$') {
            Add-CheckError "$relativePath frontmatter has no tags"
        }
        if ($content -notmatch '(?m)^updated:\s*\d{4}-\d{2}-\d{2}\s*$') {
            Add-CheckError "$relativePath frontmatter has no valid updated date"
        }
    }
    if ($content -match '!\[[^\]]*\]\(https?://') {
        Add-CheckError "$relativePath contains an externally hosted image"
    }
    if ($content -match '(?i)file:///|[A-Z]:\\(?:Users|Documents and Settings)\\') {
        Add-CheckError "$relativePath contains an absolute local path"
    }
    if ($docsRelativePath -ne 'README.md' -and
        $docsRelativePath -ne 'SUMMARY.md' -and
        $docsRelativePath -notmatch '^(?:[a-z0-9-]+/)*(?:README|[a-z0-9-]+)\.md$') {
        Add-CheckError "$relativePath is not a URL-friendly Markdown path"
    }

    # Code such as `table[0](value)` is not a Markdown link.
    $contentWithoutCode = [regex]::Replace($content, '(?s)```.*?```', '')
    $contentWithoutCode = [regex]::Replace($contentWithoutCode, '`[^`\r\n]+`', '')
    if ($docsRelativePath -ne 'SUMMARY.md') {
        $h1Count = [regex]::Matches($contentWithoutCode, '(?m)^#\s+.+$').Count
        if ($h1Count -ne 1) {
            Add-CheckError "$relativePath must contain exactly one level-1 heading (found $h1Count)"
        }
    }
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

$summaryTargetSet = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($target in $summaryTargets) {
    [void]$summaryTargetSet.Add($target.Replace('\', '/'))
}
foreach ($file in $markdownFiles) {
    $docsRelativePath = [IO.Path]::GetRelativePath($docsRoot, $file.FullName).Replace('\', '/')
    if ($docsRelativePath -ne 'SUMMARY.md' -and -not $summaryTargetSet.Contains($docsRelativePath)) {
        Add-CheckError "$docsRelativePath is not present in SUMMARY.md"
    }
}

$contentDirectories = Get-ChildItem -LiteralPath $docsRoot -Recurse -Directory
foreach ($directory in $contentDirectories) {
    if (-not (Test-Path -LiteralPath (Join-Path $directory.FullName 'README.md') -PathType Leaf)) {
        $relativeDirectory = [IO.Path]::GetRelativePath($repositoryRoot, $directory.FullName).Replace('\', '/')
        Add-CheckError "$relativeDirectory has no README.md index"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Documentation checks passed: $($markdownFiles.Count) Markdown files, $($summaryTargets.Count) SUMMARY entries."
