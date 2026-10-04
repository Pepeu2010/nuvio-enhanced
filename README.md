# Nuvio Enhanced workspace

Independent native Desktop and Android TV forks. This workspace coordinates
the architecture audit, pinned upstream references, validation and milestones.
It is not an official Nuvio client.

Application source checkouts live in `repos/desktop` and `repos/tv`; upstream
research checkouts live in `references`. Each preserves its own Git history.
Build outputs, local configuration and credentials must not be committed here.

The approved product specification is in `docs/APPROVED_SPEC.md` and milestones
are tracked in `docs/ROADMAP.md`.

## Validation

`Initialize-Workspace.ps1` restores the pinned checkouts on a new machine and
preserves existing Git checkouts and local work.

Run scripts in the same PowerShell session so local development signing settings
remain available to Gradle:

```powershell
.\scripts\Test-Workspace.ps1
.\scripts\Initialize-Development.ps1 -Target tv
.\scripts\Invoke-Baseline.ps1 -Target tv -Label baseline-configured
```

Desktop additionally requires the WebView2 SDK version recorded in
`docs/BASELINE.md`, passed with `-GradleArgs` as `-Pnuvio.webview2.dir=<SDK path>`.
Use `--no-configuration-cache`, as the upstream release CI does. Sources remain
unchanged; ignored local properties and tools configure the build. Execute large
builds sequentially on memory-constrained hosts.

`Export-Baseline.ps1` records attempt outcomes and XML test counts, while
`Export-ContractInventory.ps1` records literal RPC call sites. Full logs and
signing material remain local and ignored. No baseline app is installed over
the user's official Nuvio installation.
