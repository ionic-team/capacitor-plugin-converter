# Capacitor Plugin Converter

> [!IMPORTANT]
> This is a *experimental* CLI tool under heavy development

This package builds a binary cap2spm that allows for the following:

- To read Plugin.m and Plugin.h files and modify your Plugin.swift file to allow them to be removed
- **COMING SOON:** you will be able to generate a Package.swift for your plugin to be useable with Capacitor SPM

The easiest way to install is via curl:
```
curl -OL https://github.com/ionic-team/capacitor-plugin-converter/releases/latest/download/cap2spm.zip
```


> [!WARNING]
> The binary in releases is currently not signed. If you download from a browser, you will have to run the following
> ```
> xattr -d com.apple.quarantine ./cap2spm
> ```
