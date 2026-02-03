# Project Information

## About

Bootable Installer Creator simplifies the process of creating bootable macOS installation media. Instead of using Terminal commands, users can create bootable USB drives through a friendly graphical interface.

## Background

Apple provides the `createinstallmedia` tool bundled within macOS installer applications. This tool is powerful but requires Terminal usage:

```bash
sudo /Applications/Install\ macOS\ Sequoia.app/Contents/Resources/createinstallmedia \
    --volume /Volumes/MyUSB --nointeraction
```

This app wraps that functionality in a native macOS interface with visual progress feedback.

## Use Cases

- **Clean macOS installations** - Install macOS on a new or reformatted drive
- **Multiple Mac setup** - Create one installer to set up several Macs
- **Troubleshooting** - Boot into installer for recovery or diagnostics
- **Offline installation** - Install macOS without internet access
- **Downgrading** - Install an older macOS version

## Supported macOS Installers

Any macOS installer that contains `createinstallmedia`:

- macOS Sequoia (15.x)
- macOS Sonoma (14.x)
- macOS Ventura (13.x)
- macOS Monterey (12.x)
- macOS Big Sur (11.x)
- macOS Catalina (10.15)
- macOS Mojave (10.14)
- macOS High Sierra (10.13)

## USB Drive Requirements

| macOS Version | Minimum Size |
|---------------|--------------|
| Sequoia, Sonoma, Ventura | 16 GB |
| Monterey, Big Sur | 14 GB |
| Catalina and earlier | 8 GB |

**Recommended:** 32 GB or larger USB 3.0 drive for faster creation and future compatibility.

## How to Get macOS Installers

### From App Store

1. Open App Store
2. Search for "macOS Sequoia" (or desired version)
3. Click "Get" to download
4. Installer appears in /Applications

### Via Terminal

```bash
# Download latest macOS
softwareupdate --fetch-full-installer

# Download specific version
softwareupdate --fetch-full-installer --full-installer-version 14.0
```

### From Apple Support

Visit [Apple's macOS download page](https://support.apple.com/en-us/HT211683) for links to older versions.

## Troubleshooting

### "Invalid Installer" Error

- Ensure you selected an "Install macOS..." app, not a different application
- Re-download the installer if it's corrupted
- Check that the app contains `Contents/Resources/createinstallmedia`

### "Failed to create" Error

- Verify the USB drive is properly mounted
- Try reformatting the USB as "Mac OS Extended (Journaled)" first
- Ensure sufficient disk space
- Check that you entered the correct admin password

### Progress Stuck

- The "Copying to disk" phase can take 20-45 minutes
- USB 2.0 drives are significantly slower than USB 3.0
- Do not disconnect the drive during creation

### Permission Denied

- Grant Terminal/app Full Disk Access in System Settings
- System Settings > Privacy & Security > Full Disk Access

## Version History

### 1.0 (Initial Release)
- Native AppKit interface
- Installer and volume selection
- Real-time progress tracking
- Password prompt via secure dialog
- Custom app icon

## Author

Created with assistance from Claude (Anthropic).

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Support

For issues or feature requests, please open a GitHub issue.
