# Capacitor Plugin Converter

> [!IMPORTANT]
> This is a *experimental* CLI tool under heavy development

This package builds a binary cap2spm that allows for the following:

- To read Plugin.m and Plugin.h files and modify your Plugin.swift file to allow them to be removed
- Generate a Package.swift for your plugin to be useable with Capacitor SPM

The easiest way to install is via curl:
```
curl -OL https://github.com/ionic-team/capacitor-plugin-converter/releases/latest/download/cap2spm.zip
```

```
USAGE: cap2spm [options] <plugin-directory>

ARGUMENTS:
  <plugin-directory>      Plugin Directory

OPTIONS:
  --backup/--no-backup    Should we make a backup? (default: --no-backup)
  --objc-header <objc-header>
                          Objective-C header for file containing CAP_PLUGIN
                          macro
  --objc-file <objc-file> Objective-C file containing CAP_PLUGIN macro
  --swift-file <swift-file>
                          Swift file containing class inheriting from CAPPlugin
  --swift-tests-file <swift-tests-file>
                          Swift file containing plugin tests
  -h, --help              Show help information.
```


> [!WARNING]
> The binary in releases is currently not signed. If you download from a browser, you will have to run the following
> ```
> xattr -d com.apple.quarantine ./cap2spm
> ```
