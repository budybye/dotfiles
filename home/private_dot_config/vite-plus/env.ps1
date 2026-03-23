# Vite+ environment setup (https://viteplus.dev)
$__vp_bin = "${HOME}/.config/vite-plus/bin"
if ($env:Path -split ';' -notcontains $__vp_bin) {
    $env:Path = "$__vp_bin;$env:Path"
}

# Shell function wrapper: intercepts `vp env use` to eval its stdout,
# which sets/unsets VITE_PLUS_NODE_VERSION in the current shell session.
function vp {
    if ($args.Count -ge 2 -and $args[0] -eq "env" -and $args[1] -eq "use") {
        if ($args -contains "-h" -or $args -contains "--help") {
            & (Join-Path $__vp_bin "vp.exe") @args; return
        }
        $env:VITE_PLUS_ENV_USE_EVAL_ENABLE = "1"
        $output = & (Join-Path $__vp_bin "vp.exe") @args 2>&1 | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                Write-Host $_.Exception.Message
            } else {
                $_
            }
        }
        Remove-Item Env:VITE_PLUS_ENV_USE_EVAL_ENABLE -ErrorAction SilentlyContinue
        if ($LASTEXITCODE -eq 0 -and $output) {
            Invoke-Expression ($output -join "`n")
        }
    } else {
        & (Join-Path $__vp_bin "vp.exe") @args
    }
}
