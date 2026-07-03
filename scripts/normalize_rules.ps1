param(
    [string]$RulesDir = (Join-Path $PSScriptRoot '..\rules')
)

$validTypes = @(
    'DOMAIN',
    'DOMAIN-SUFFIX',
    'DOMAIN-KEYWORD',
    'DOMAIN-REGEX',
    'IP-CIDR',
    'IP-CIDR6',
    'IP-ASN',
    'GEOIP',
    'GEOSITE',
    'PROCESS-NAME',
    'PROCESS-PATH',
    'DST-PORT',
    'SRC-IP-CIDR',
    'SRC-PORT',
    'RULE-SET'
)

function Normalize-Line {
    param([string]$Line)

    $trimmed = $Line.Trim()
    if ($trimmed.Length -eq 0) {
        return ''
    }
    if ($trimmed.StartsWith('#')) {
        return $trimmed
    }

    if ($trimmed.StartsWith('+.')) {
        $domain = $trimmed.Substring(2).Trim()
        if ($domain.Length -gt 0) {
            return "DOMAIN-SUFFIX,$domain"
        }
    }

    $first = ($trimmed.Split(',', 2)[0]).Trim().ToUpperInvariant()
    if ($validTypes -contains $first) {
        return $trimmed
    }

    if ($trimmed -match '^[A-Za-z0-9_-]+(\.[A-Za-z0-9_-]+)+$') {
        return "DOMAIN,$trimmed"
    }

    return $trimmed
}

Get-ChildItem -Path $RulesDir -Filter '*.list' -File | Sort-Object Name | ForEach-Object {
    $normalized = [System.Collections.Generic.List[string]]::new()
    foreach ($line in Get-Content -LiteralPath $_.FullName) {
        $normalized.Add((Normalize-Line -Line $line))
    }

    Set-Content -LiteralPath $_.FullName -Value $normalized -Encoding utf8
}
