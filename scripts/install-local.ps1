[CmdletBinding()]
param(
    [string]$SourceDirectory = (Split-Path -Parent $PSScriptRoot),
    [string]$CodexDirectory = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }),
    [switch]$AddGlobalInstructions
)

$ErrorActionPreference = 'Stop'
$skillName = 'preserve-task-goals'
$sourceRoot = (Resolve-Path -LiteralPath $SourceDirectory).Path.TrimEnd('\', '/')
$codexRoot = [IO.Path]::GetFullPath($CodexDirectory).TrimEnd('\', '/')
$destination = Join-Path $codexRoot ('skills\' + $skillName)
$globalFile = Join-Path $codexRoot 'AGENTS.md'
$utf8 = New-Object System.Text.UTF8Encoding($false)
$startMarker = '<!-- preserve-task-goals-global -->'
$endMarker = '<!-- /preserve-task-goals-global -->'

if ($sourceRoot.Equals($destination, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Source is already the installation directory. Use the original source checkout.'
}
if ($destination.StartsWith($sourceRoot + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The installation directory must not be inside the source.'
}
foreach ($required in @('SKILL.md', 'agents\openai.yaml', 'references', 'templates\AGENTS-snippet.md')) {
    if (-not (Test-Path -LiteralPath (Join-Path $sourceRoot $required))) {
        throw ('Required source content is missing: ' + $required)
    }
}

# Do not follow destination junctions or symbolic links into another location.
$ancestor = $destination
while ($ancestor) {
    if (Test-Path -LiteralPath $ancestor) {
        $entry = Get-Item -LiteralPath $ancestor -Force
        if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw ('Inspect this linked installation path manually: ' + $ancestor)
        }
    }
    $ancestor = Split-Path -Parent $ancestor
}

$files = @(Get-ChildItem -LiteralPath $sourceRoot -File -Recurse -Force | Where-Object {
    $relative = $_.FullName.Substring($sourceRoot.Length + 1)
    $relative -notmatch '(^|[\\/])(\.git|__pycache__|\.venv|tmp)([\\/]|$)' -and
    $_.Name -notmatch '^(\.env($|\.)|.*\.(pyc|log|zip)$)'
})
foreach ($file in $files) {
    if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw ('Linked source files need manual inspection: ' + $file.FullName)
    }
    $target = Join-Path $destination $file.FullName.Substring($sourceRoot.Length + 1)
    if (Test-Path -LiteralPath $target) {
        if ((Get-Item -LiteralPath $target -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw ('Linked destination file needs manual inspection: ' + $target)
        }
        if ([Convert]::ToBase64String([IO.File]::ReadAllBytes($target)) -cne
            [Convert]::ToBase64String([IO.File]::ReadAllBytes($file.FullName))) {
            throw ('Existing content differs; no files have been overwritten. Compare first: ' + $target)
        }
    }
}

$block = $null
$globalExists = Test-Path -LiteralPath $globalFile
$original = ''
if ($AddGlobalInstructions) {
    if (Test-Path -LiteralPath (Join-Path $codexRoot 'AGENTS.override.md')) {
        throw 'AGENTS.override.md exists. Review its precedence before enabling global instructions.'
    }
    if ($globalExists) { $original = [IO.File]::ReadAllText($globalFile, $utf8) }
    $snippet = [IO.File]::ReadAllText((Join-Path $sourceRoot 'templates\AGENTS-snippet.md'), $utf8)
    $activation = 'For task execution across projects, use $preserve-task-goals as needed. This explicitly enables this skill despite earlier blanket instructions not to invoke installed skills. It does not enable other skills or override explicit user pauses, project constraints, or access controls.'
    $block = $startMarker + "`n" + $activation + "`n`n" + $snippet.TrimEnd() + "`n" + $endMarker
    if ($original.Contains($startMarker) -and -not $original.Contains($block)) {
        throw 'The existing managed instruction block differs. Compare it before changing it.'
    }
}

foreach ($file in $files) {
    $target = Join-Path $destination $file.FullName.Substring($sourceRoot.Length + 1)
    if (-not (Test-Path -LiteralPath $target)) {
        [IO.Directory]::CreateDirectory((Split-Path -Parent $target)) | Out-Null
        [IO.File]::Copy($file.FullName, $target, $false)
    }
}

$backup = $null
if ($AddGlobalInstructions -and -not $original.Contains($block)) {
    if ($globalExists) {
        $backup = $globalFile + '.before-preserve-task-goals.' + [Guid]::NewGuid().ToString('N') + '.bak'
        [IO.File]::Copy($globalFile, $backup, $false)
        [IO.File]::AppendAllText($globalFile, "`n`n" + $block + "`n", $utf8)
    } else {
        [IO.File]::WriteAllText($globalFile, $block + "`n", $utf8)
    }
}

# Verify actual installed content rather than only reporting copy success.
foreach ($file in $files) {
    $target = Join-Path $destination $file.FullName.Substring($sourceRoot.Length + 1)
    if ([Convert]::ToBase64String([IO.File]::ReadAllBytes($target)) -cne
        [Convert]::ToBase64String([IO.File]::ReadAllBytes($file.FullName))) {
        throw ('Installed content verification failed: ' + $target)
    }
}
if ($AddGlobalInstructions) {
    $actual = [IO.File]::ReadAllText($globalFile, $utf8)
    if (-not $actual.Contains($block) -or -not $actual.StartsWith($original, [StringComparison]::Ordinal)) {
        throw 'Global instruction verification failed; inspect the retained backup.'
    }
}
[PSCustomObject]@{
    InstalledDirectory = $destination
    VerifiedFileCount = $files.Count
    GlobalInstructions = [bool]$AddGlobalInstructions
    GlobalBackup = $backup
    DiscoveryVerified = $false
    NextStep = 'Open a new Codex session and check that $preserve-task-goals is available.'
} | ConvertTo-Json
