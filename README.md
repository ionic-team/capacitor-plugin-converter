# Capacitor Plugin Converter

> [!IMPORTANT]
> This is a *experimental* CLI tool under heavy development

This package builds a binary cap2spm that allows for the following:

- To read Plugin.m and Plugin.h files and modify your Plugin.swift file to allow them to be removed
- **COMING SOON:** you will be able to generate a Package.swift for your plugin to be useable with Capacitor SPM

> [!WARNING]
> The binary in releases is currently not signed.
>
> Build it from source or run the following on the command line to allow you to run it:
> ```
> xattr -d com.apple.quarantine ./cap2spm
> ```
