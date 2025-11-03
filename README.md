# simreader - Unified SIM/USIM Card Reader Tool

A comprehensive command-line tool for reading and analyzing SIM and USIM cards on Linux systems. Designed for modern 3G/4G/5G USIM cards with backward compatibility for traditional 2G SIM cards.

## Features

- **Universal Compatibility**: Works with both traditional SIM and modern USIM cards
- **Complete Analysis**: Detailed exploration of 57+ different SIM/USIM files
- **Multiple Output Formats**: Human-readable, JSON, and verbose modes
- **Smart Recommendations**: Provides guidance when contacts aren't found on SIM
- **AUR Ready**: Packaged for Arch Linux User Repository

## What simreader CAN Extract

✅ **Basic Information**
- ICCID (SIM serial number)
- IMSI (subscriber identity)
- SPN (service provider name)
- MSISDN (subscriber phone number)

✅ **Network Settings**
- PLMN selectors and preferences
- Access control classes
- Emergency call codes
- Language preferences

✅ **Technical Data**
- File structure analysis
- Service parameters
- Location information

## What simreader CANNOT Extract

❌ **Contacts** (stored in phone memory or cloud)
❌ **SMS Messages** (stored in phone memory)
❌ **Call History** (stored in phone, not SIM)
❌ **Photos, Videos, Apps** (stored in phone memory/storage)

## Installation

### From AUR (Recommended)

```bash
# Using yay
yay -S simreader

# Using paru
paru -S simreader

# Manual installation
git clone https://aur.archlinux.org/simreader.git
cd simreader
makepkg -si
```

### Manual Installation

```bash
# Install dependencies
sudo pacman -S pcsclite gcc

# Clone and build
git clone https://github.com/mango/simreader.git
cd simreader
gcc -o simreader src/simreader.c -lpcsclite -I/usr/include/PCSC
sudo install simreader /usr/local/bin/
```

## Usage

### Basic Usage

```bash
# Basic SIM information
simreader

# Complete analysis with recommendations
simreader -a

# Explore all files with verbose output
simreader -e -v

# JSON output for scripting
simreader -j
```

### Command Line Options

- `-v, --verbose`: Show APDUs and hex dumps
- `-j, --json`: Output in JSON format
- `-e, --explore`: Explore all accessible SIM files
- `-a, --analysis`: Complete analysis with recommendations
- `-r, --reader NAME`: Specify reader name
- `-h, --help`: Show help message
- `--version`: Show version information

### Examples

```bash
# Quick check of SIM card
$ simreader
=== SIM Card Information ===
IMSI:    895203100006607
ICCID:   8952031000066073278
MSISDN:  Not available
SPN:     Your Mobile Provider

# Complete analysis (recommended for new users)
$ simreader -a
=== Complete SIM Card Analysis ===
📱 SIM Card Type Detection:
This appears to be a modern USIM (Universal Subscriber Identity Module) card...
[Full analysis with recommendations]

# JSON output for automation
$ simreader -j
{
  "imsi": "895203100006607",
  "iccid": "8952031000066073278",
  "msisdn": "null",
  "spn": "Your Mobile Provider"
}
```

## Sample Output

### Human-readable format
```
=== SIM Card Information ===
IMSI:    310150123456789
ICCID:   89014103211118510720
MSISDN:  +14155552671
SPN:     T-Mobile
```

### JSON format
```json
{
  "imsi": "310150123456789",
  "iccid": "89014103211118510720",
  "msisdn": "+14155552671",
  "spn": "T-Mobile"
}
```

### Verbose output
```
Using reader: ACS ACR38U 00 00
ATR: 3B9F96801FC78031E073FE211B664FF83000090
ICCID raw: 98 10 41 03 21 11 18 51 07 20
IMSI raw: 08 91 31 01 50 21 43 65 87 29
MSISDN raw: 0B 81 41 55 55 26 71 FF
SPN raw: FF 54 2D 4D 6F 62 69 6C 65
=== SIM Card Information ===
IMSI:    310150123456789
ICCID:   89014103211118510720
MSISDN:  14155552671
SPN:     T-Mobile
```

## Hardware Requirements

- **Compatible Reader**: ACS ACR38U-CCID or similar PC/SC compliant reader
- **SIM Card**: Any standard SIM/USIM card
- **Permissions**: Access to PC/SC daemon (usually handled by system)

### Setting up PC/SC

```bash
# Install and start PC/SC service
sudo pacman -S pcsclite
sudo systemctl enable --now pcscd

# Add user to uucp group (if needed)
sudo usermod -a -G uucp $USER
# Log out and back in
```

## Troubleshooting

### "No compatible reader found"
- Check if reader is connected: `lsusb | grep -i acr`
- Verify PC/SC service: `sudo systemctl status pcscd`
- Check reader permissions: `sudo chmod 666 /dev/bus/usb/*/*/`

### "Failed to connect to card"
- Ensure SIM card is properly inserted
- Try removing and reinserting the card
- Check if another application is using the reader

### Compilation Issues
```bash
# Ensure development packages are installed
sudo pacman -S pcsclite gcc

# Compile with explicit paths
gcc -o simreader src/simreader.c -lpcsclite -I/usr/include/PCSC
```

## Development

### Building from Source

```bash
# Clone repository
git clone https://github.com/mango/simreader.git
cd simreader

# Build
make

# Install (optional)
sudo make install
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with various SIM cards
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- PC/SC Lite project for smart card support
- ACS for ACR38U-CCID reader compatibility
- ETSI standards for SIM/USIM specifications

## Support

- **Issues**: [GitHub Issues](https://github.com/mango/simreader/issues)
- **Documentation**: [Man page](simreader.1) (`man simreader`)
- **AUR Package**: [simreader on AUR](https://aur.archlinux.org/packages/simreader/)

---

**Note**: Modern smartphones typically store contacts in phone memory or cloud services rather than on the SIM card. This is normal behavior. Use your phone's built-in export functions or cloud services to extract contacts.

## Technical Details

### APDU Commands Used
- `00 A4 04 00 02 3F 00` - Select MF (Master File)
- `00 A4 04 00 02 7F 20` - Select DF_GSM
- `00 A4 04 00 02 6F 07` - Select EF_IMSI
- `00 B0 00 00 09` - Read binary (IMSI)
- `00 A4 04 00 02 2F E2` - Select EF_ICCID
- `00 B0 00 00 0A` - Read binary (ICCID)

### File Paths
- **MF**: 3F00 (Master File)
- **DF_GSM**: 7F20 (GSM dedicated file)
- **DF_TELECOM**: 7F10 (Telecom dedicated file)
- **EF_IMSI**: 6F07 (IMSI file)
- **EF_ICCID**: 2FE2 (ICCID file)
- **EF_MSISDN**: 6F40 (MSISDN file)
- **EF_SPN**: 6F46 (Service Provider Name file)

### Data Encoding
- **IMSI**: BCD encoding, first byte indicates length
- **ICCID**: BCD encoding, up to 20 digits
- **MSISDN**: BCD encoding with TON/NPI prefix
- **SPN**: ASCII encoding with display condition byte

## Security Notes

- No PIN verification is implemented by default
- The tool does not store or transmit any card data
- Use with caution on systems with multiple users
- Consider file permissions when installing system-wide

## License

MIT License - see source code for details.

## Contributing

This tool is designed for educational and research purposes. When contributing:
- Follow existing code style
- Add appropriate error handling
- Test with different SIM card types
- Update documentation for new features

## References

- PC/SC Lite API documentation
- ETSI TS 102 221 (UICC specification)
- 3GPP TS 31.102 (USIM specification)
- GSM 11.11 (SIM specification)
- ISO/IEC 7816 (Smart card standard)