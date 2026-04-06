# GreeterApp — WiX Windows Installer Test

## Project Overview

**GreeterApp** — Minimal .NET 10 CLI app packaged as a Windows `.msi` installer via WiX Toolset v4. This is a proof-of-concept for learning WiX-based Windows installer packaging with CI/CD.

## Tech Stack

- .NET 10 (C#, top-level statements)
- WiX Toolset v4 (installed as `dotnet tool install --global wix`)
- GitHub Actions (Windows runner)

## Repo Structure

```
src/GreeterApp/          → .NET CLI app (reads appsettings.json, prints greeting)
installer/Package.wxs    → WiX product definition, custom action, feature
installer/ConfigDialog.wxs → Custom UI dialog (Greeting + Recipient fields)
installer/scripts/Set-AppSettings.ps1 → Patches {{placeholders}} in appsettings.json
.github/workflows/build.yml → CI: publish → wix build → GitHub Release
```

## Build Commands (Windows only)

```bash
# Publish
dotnet publish src/GreeterApp/GreeterApp.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./publish/win-x64

# Install WiX + extensions (once)
dotnet tool install --global wix
wix extension add WixToolset.UI.wixext
wix extension add WixToolset.Util.wixext

# Build MSI
wix build installer/Package.wxs installer/ConfigDialog.wxs \
  -ext WixToolset.UI.wixext -ext WixToolset.Util.wixext \
  -d PublishDir=./publish/win-x64 -d InstallerDir=./installer \
  -o ./output/GreeterApp.msi
```

## Key Design Decisions

- `appsettings.json` ships with `{{PLACEHOLDER}}` tokens, replaced at install time by `Set-AppSettings.ps1` (WiX deferred custom action via `WixQuietExec`).
- Installer exposes `GREETING` and `RECIPIENT` as public MSI properties (settable via UI dialog or `msiexec /qn GREETING="..." RECIPIENT="..."`).
- Single-file self-contained publish (`PublishSingleFile=true`) so `Package.wxs` only needs to reference `GreeterApp.exe` + `appsettings.json`.

## Known Issues / TODOs

- WiX v4 `BinaryRef="Wix4UtilCA_X86"` name may differ by Util extension version — verify against actual build output.
- .NET 10 is preview; `setup-dotnet` may need `include-prerelease: true`.
- No code-signing configured yet.