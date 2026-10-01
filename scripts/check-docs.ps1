[CmdletBinding()]
param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot '..')
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = [IO.Path]::GetFullPath($RepositoryRoot)
$docsRoot = Join-Path $repositoryRoot 'docs'
$summaryPath = Join-Path $docsRoot 'SUMMARY.md'
$errors = [Collections.Generic.List[string]]::new()

function Add-CheckError([string]$message) {
    $errors.Add($message)
}

function Remove-FencedCode([string]$text) {
    return [regex]::Replace($text, '(?ms)^ {0,3}(`{3,}|~{3,})[^\r\n]*\r?\n.*?^ {0,3}\1[ \t]*\r?$', '')
}

$anchorCache = @{}
function Get-MarkdownAnchors([string]$path) {
    if ($anchorCache.ContainsKey($path)) { return ,$anchorCache[$path] }
    $anchors = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $counts = @{}
    $text = Remove-FencedCode (Get-Content -Raw -LiteralPath $path)
    foreach ($heading in [regex]::Matches($text, '(?m)^ {0,3}#{1,6}\s+(.+?)\s*#*\s*$')) {
        $label = $heading.Groups[1].Value
        if ($label -match '\{#([^}]+)\}\s*$') {
            [void]$anchors.Add($Matches[1])
            $label = $label -replace '\s*\{#[^}]+\}\s*$', ''
        }
        $label = [regex]::Replace($label, '\[([^\]]+)\]\([^)]+\)', '$1')
        $slug = ($label.ToLowerInvariant() -replace '<[^>]+>', '' -replace '[^\p{L}\p{N}\p{M}_\-\s]', '') -replace '\s', '-'
        $number = if ($counts.ContainsKey($slug)) { $counts[$slug] } else { 0 }
        $counts[$slug] = $number + 1
        if ($number -gt 0) { $slug = "$slug-$number" }
        [void]$anchors.Add($slug)
    }
    foreach ($id in [regex]::Matches($text, '(?i)\b(?:id|name)=["'']([^"'']+)["'']')) {
        [void]$anchors.Add($id.Groups[1].Value)
    }
    $anchorCache[$path] = $anchors
    return ,$anchors
}

function Test-LocalDestination([IO.FileInfo]$file, [string]$destination) {
    $relativePath = [IO.Path]::GetRelativePath($repositoryRoot, $file.FullName).Replace('\', '/')
    $destination = $destination.Trim()
    if ($destination.StartsWith('<')) {
        $destination = ($destination -split '>', 2)[0].Substring(1)
    } else {
        $destination = ($destination -split '\s+["'']', 2)[0]
    }
    if ($destination -match '^(?:[a-z][a-z0-9+.-]*:|//)') { return }
    $parts = $destination -split '#', 2
    $target = ($parts[0] -split '\?', 2)[0]
    try {
        $decoded = [Uri]::UnescapeDataString($target).Replace('/', [IO.Path]::DirectorySeparatorChar)
        $resolved = if ($target.Length -eq 0) { $file.FullName } else {
            [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $decoded))
        }
        if (-not (Test-Path -LiteralPath $resolved)) {
            Add-CheckError "$relativePath -> missing local target: $destination"
        } elseif ($parts.Count -gt 1 -and $parts[1] -and [IO.Path]::GetExtension($resolved) -eq '.md') {
            $fragment = [Uri]::UnescapeDataString($parts[1])
            if (-not (Get-MarkdownAnchors $resolved).Contains($fragment)) {
                Add-CheckError "$relativePath -> missing Markdown anchor: $destination"
            }
        }
    } catch {
        Add-CheckError "$relativePath -> invalid local target: $destination ($($_.Exception.Message))"
    }
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
        $frontmatterMatch = [regex]::Match($content, '(?s)\A---\r?\n(.+?)\r?\n---\r?\n')
        if (-not $frontmatterMatch.Success) {
            Add-CheckError "$relativePath has malformed frontmatter delimiters"
        }
        $frontmatter = $frontmatterMatch.Groups[1].Value
        $keys = [regex]::Matches($frontmatter, '(?m)^([a-z][a-z0-9_-]*):') | ForEach-Object { $_.Groups[1].Value }
        foreach ($duplicate in ($keys | Group-Object | Where-Object Count -gt 1)) {
            Add-CheckError "$relativePath frontmatter contains duplicate key: $($duplicate.Name)"
        }
        foreach ($scalar in [regex]::Matches($frontmatter, '(?m)^(?:title|description):[ \t]*(.+)$')) {
            $value = $scalar.Groups[1].Value.Trim()
            if ($value -notmatch '^["'']' -and $value -match ':\s') {
                Add-CheckError "$relativePath frontmatter scalar containing colon must be quoted"
            }
        }
        if ($frontmatter -notmatch '(?m)^title:[ \t]*\S[^\r\n]*\r?$') {
            Add-CheckError "$relativePath frontmatter has no title"
        }
        if ($frontmatter -notmatch '(?m)^description:[ \t]*\S[^\r\n]*\r?$') {
            Add-CheckError "$relativePath frontmatter has no description"
        }
        if ($frontmatter -notmatch '(?m)^tags:[ \t]*(?:\[[^\]\r\n]+\][ \t]*\r?$|\r?\n(?:[ \t]+-[ \t]+\S[^\r\n]*\r?\n?)+)') {
            Add-CheckError "$relativePath frontmatter has no nonempty tags list"
        }
        $dateMatch = [regex]::Match($frontmatter, '(?m)^updated:[ \t]*(\d{4}-\d{2}-\d{2})[ \t]*\r?$')
        $parsedDate = [datetime]::MinValue
        if (-not $dateMatch.Success -or -not [datetime]::TryParseExact(
            $dateMatch.Groups[1].Value, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture,
            [Globalization.DateTimeStyles]::None, [ref]$parsedDate)) {
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
    $contentWithoutCode = Remove-FencedCode $content
    $contentWithoutCode = [regex]::Replace($contentWithoutCode, '`[^`\r\n]+`', '')
    if ($docsRelativePath -ne 'SUMMARY.md') {
        $h1Count = [regex]::Matches($contentWithoutCode, '(?m)^#\s+.+$').Count
        if ($h1Count -ne 1) {
            Add-CheckError "$relativePath must contain exactly one level-1 heading (found $h1Count)"
        }
    }
    $matches = [regex]::Matches($contentWithoutCode, '!?(?<!\!)\[[^\]]*\]\(([^)]+)\)')
    foreach ($match in $matches) {
        Test-LocalDestination $file $match.Groups[1].Value
    }
    $definitions = @{}
    foreach ($definition in [regex]::Matches($contentWithoutCode, '(?m)^ {0,3}\[([^\]]+)\]:[ \t]*(<[^>]+>|\S+)')) {
        $label = ($definition.Groups[1].Value.Trim() -replace '\s+', ' ').ToLowerInvariant()
        $definitions[$label] = $definition.Groups[2].Value
        Test-LocalDestination $file $definition.Groups[2].Value
    }
    foreach ($reference in [regex]::Matches($contentWithoutCode, '!?\[([^\]\r\n]+)\]\[([^\]\r\n]*)\]')) {
        $label = if ($reference.Groups[2].Value) { $reference.Groups[2].Value } else { $reference.Groups[1].Value }
        $label = ($label.Trim() -replace '\s+', ' ').ToLowerInvariant()
        if (-not $definitions.ContainsKey($label)) {
            Add-CheckError "$relativePath -> undefined reference link: $label"
        }
    }
    foreach ($asset in [regex]::Matches($contentWithoutCode, '(?i)<(?:img|source)\b[^>]*\bsrc=["'']([^"'']+)["'']')) {
        Test-LocalDestination $file $asset.Groups[1].Value
    }
}

$summary = Get-Content -Raw -LiteralPath $summaryPath
$summaryTargets = [regex]::Matches($summary, '\[[^\]]+\]\(([^)]+)\)') |
    ForEach-Object {
        $target = ($_.Groups[1].Value -split '#', 2)[0].Trim('<', '>')
        $resolved = [IO.Path]::GetFullPath((Join-Path $docsRoot ([Uri]::UnescapeDataString($target))))
        $normalized = [IO.Path]::GetRelativePath($docsRoot, $resolved).Replace('\', '/')
        if ($normalized.StartsWith('../') -or [IO.Path]::GetExtension($resolved) -ne '.md') {
            Add-CheckError "SUMMARY.md -> target must be a Markdown page inside docs: $target"
        }
        $normalized
    }
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
    if (-not (Get-ChildItem -LiteralPath $directory.FullName -Recurse -File -Filter '*.md')) { continue }
    if (-not (Test-Path -LiteralPath (Join-Path $directory.FullName 'README.md') -PathType Leaf)) {
        $relativeDirectory = [IO.Path]::GetRelativePath($repositoryRoot, $directory.FullName).Replace('\', '/')
        Add-CheckError "$relativeDirectory has no README.md index"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { [Console]::Error.WriteLine($_) }
    exit 1
}

Write-Host "Documentation checks passed: $($markdownFiles.Count) Markdown files, $($summaryTargets.Count) SUMMARY entries."
