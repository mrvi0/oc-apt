# oc-htop

Advanced system monitor for OpenComputers inspired by the classic htop utility.

## Overview

oc-htop provides real-time monitoring of your OpenComputers system with a beautiful, interactive interface. Monitor memory usage, energy consumption, disk space, and running processes all in one place.

## Features

- 🖥️ **Real-time system monitoring**
- 📊 **Memory usage with visual progress bars**
- ⚡ **Energy consumption tracking** (if available)
- 💾 **Disk space visualization**
- 🔄 **Process list with detailed information**
- 🎨 **Color-coded interface** with status indicators
- ⌨️ **Interactive controls** for navigation and sorting
- 📈 **CPU activity monitoring**
- 🕐 **System uptime display**

## Installation

### Using OC-APT
```bash
apt update
apt install oc-htop
```

### Manual Installation
```bash
wget https://raw.githubusercontent.com/mrvi0/oc-apt/main/packages/oc-htop/oc-htop.lua
mv oc-htop.lua /usr/bin/
chmod +x /usr/bin/oc-htop.lua
```

## Usage

### Starting oc-htop
```bash
oc-htop.lua
```

Or if you've created a symlink:
```bash
htop
```

### Controls

| Key | Action |
|-----|--------|
| `q` | Quit the application |
| `h` | Show/hide help panel |
| `s` | Change sorting (PID → Name → State) |
| `+` / `-` | Increase/decrease refresh rate |
| `↑` / `↓` | Scroll process list up/down |
| `j` / `k` | Scroll process list (vim-style) |
| `PgUp` / `PgDn` | Scroll by 10 processes |
| `g` | Go to top of process list |
| `G` | Go to bottom of process list |
| `r` | Reset scroll position |

## Interface

### Header Bar
- **Title**: Application name
- **Uptime**: System uptime in HH:MM:SS format
- **Activity**: CPU activity percentage based on frame render time
- **Refresh Rate**: Current refresh frequency in Hz
- **Sort Mode**: Current process sorting method

### System Metrics
- **Memory**: RAM usage with visual bar (Used / Total)
- **Energy**: Internal computer energy buffer (if available)
- **Disk**: Storage space usage for primary filesystem

### Process List
- **PID**: Process ID number
- **STATE**: Current process state (running, sleeping, dead, etc.)
- **NAME**: Process name or command

### Color Coding
- 🟢 **Green**: Good status (< 60% usage)
- 🟡 **Yellow**: Warning status (60-85% usage)  
- 🔴 **Red**: Critical status (> 85% usage)
- 🔵 **Blue**: Accent color for highlights
- ⚪ **Gray**: Dimmed text for headers and help

## Requirements

- **OpenComputers**: Minecraft 1.7.10 mod
- **Components**: GPU + Screen
- **Memory**: 256KB RAM minimum
- **Storage**: 128KB free space
- **OpenOS**: Compatible with standard OpenOS

## Configuration

The application uses internal configuration that can be modified by editing the source file:

```lua
local cfg = {
  refresh = 0.5,        -- Refresh period in seconds
  minRefresh = 0.1,     -- Minimum refresh rate
  maxRefresh = 5.0,     -- Maximum refresh rate
  barsWidth = 30,       -- Width of progress bars
  showHelp = false,     -- Help panel visibility
  sort = "pid",         -- Default sort mode
  title = "oc-htop",    -- Window title
}
```

## Troubleshooting

### Common Issues

**"No GPU component found"**
- Ensure you have a GPU and Screen connected
- Check component availability with `components` command

**"Process list is empty"**
- This is normal on fresh systems with minimal processes
- OpenOS creates processes dynamically

**"Energy bar not showing"**
- Energy monitoring requires power storage (capacitors)
- Some computer configurations don't have energy components

**"Performance issues"**
- Try increasing refresh rate with `-` key
- Close unnecessary background processes
- Check available memory

### Performance Tips

1. **Optimal refresh rate**: 0.5-1.0 seconds for most systems
2. **Memory usage**: Close unused programs to free RAM
3. **Screen resolution**: Lower resolutions improve performance
4. **Background processes**: Minimize running processes

## Technical Details

### System Metrics Collection
- **Memory**: Uses `computer.totalMemory()` and `computer.freeMemory()`
- **Energy**: Uses `computer.maxEnergy()` and `computer.energy()`
- **Disk**: Queries first available filesystem component
- **Processes**: Uses OpenOS `process.list()` and `process.info()`

### Activity Calculation
CPU activity is estimated by measuring the time spent rendering each frame relative to the refresh period:
```
Activity = Frame_Render_Time / Refresh_Period
```

### Process Information
The process list shows all OpenOS processes with available information:
- PID from process.list()
- State from process.info()
- Name from various process.info() fields

## License

MIT License - see the main project license for details.

## Author

**B4DCAT** - Original developer  
**OC-APT Project** - Package maintenance

## Contributing

1. Fork the main OC-APT repository
2. Make your changes to the oc-htop package
3. Test thoroughly on different OpenComputers configurations
4. Submit a pull request with detailed description

## Changelog

### Version 1.0.0
- Initial release
- Full htop-like functionality
- Real-time system monitoring
- Interactive process management
- Color-coded interface
- Keyboard navigation
- Configurable refresh rates
- Help system

---

**Part of the [OC-APT Package Manager](https://github.com/mrvi0/oc-apt) project** 