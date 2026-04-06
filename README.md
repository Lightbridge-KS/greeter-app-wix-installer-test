# GreeterApp — WiX v4 MSI Installer Example

Minimal .NET 10 CLI app packaged as a Windows `.msi` installer using WiX Toolset v4.

## What It Does

Reads `appsettings.json` and prints a greeting:

```
Hello, Ramathibodi Hospital!
App Version: 1.0.0
Install Path: C:\Program Files\GreeterApp\
```

## Installer Features

- Custom UI dialog for **Greeting** and **Recipient** fields
- Values patched into `appsettings.json` via PowerShell custom action
- Supports silent install with properties:
  ```
  msiexec /i GreeterApp-1.0.0.msi /qn GREETING="Hi" RECIPIENT="Hospital"
  ```
- Major upgrade support (installs over previous versions)

## Project Structure

```
greeter-app/
├── src/GreeterApp/          # .NET 10 CLI app
│   ├── Program.cs
│   ├── appsettings.json     # template with {{placeholders}}
│   └── GreeterApp.csproj
├── installer/
│   ├── Package.wxs          # WiX product definition
│   ├── ConfigDialog.wxs     # Custom UI dialog
│   └── scripts/
│       └── Set-AppSettings.ps1
├── .github/workflows/
│   └── build.yml            # CI: build + .msi + GitHub Release
└── GreeterApp.sln
```

## Local Build

```bash
# 1. Publish the app
dotnet publish src/GreeterApp/GreeterApp.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -o ./publish/win-x64

# 2. Install WiX v4 (once)
dotnet tool install --global wix
wix extension add WixToolset.UI.wixext
wix extension add WixToolset.Util.wixext

# 3. Build the MSI
wix build installer/Package.wxs installer/ConfigDialog.wxs -ext WixToolset.UI.wixext -ext WixToolset.Util.wixext -d PublishDir=./publish/win-x64 -d InstallerDir=./installer -o ./output/GreeterApp.msi
```

## CI/CD

Push a version tag to trigger the GitHub Actions workflow:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This builds the `.msi` and attaches it to a GitHub Release.
