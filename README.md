# About
**MeteoShell** is a **software package** for monthly station meteorological data storage, processing, visualization and analysis. MeteoShell uses **Firebird/PostgreSQL** database server providing a fast data access. The software is a user interface to a scientific quality meteorological database compiled from different initial sources.
A user-friendly graphical interface offers **tools** necessary for data **download** (multiple formats), meteorological stations **selection** from the database (by time, region, data source, variable name, interactively on a globe etc.), **editing** of metadata and values, **import/export**, **database statistics**, and **visualization** (external graphical software is used).

# Installation

## Supported systems (x64 only)
- Windows (v7 and above)
- Linux (tested on Ubuntu v16.0 and above)
- macOS (v10.15 and newer). 

### Windows
1. Download the binaries for [Windows](https://github.com/OceanShell/MeteoShell/releases/download/v0.1-alpha/MeteoShell-0.1-alpha-win64.zip)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)

### Linux
1. Download the binaries for [Linux](https://github.com/OceanShell/OceanShell/releases/download/v.0.1-alpha/linux_x86-64.tar.gz)
2. Unpack the package in any folder which is accessible for writing (User's folder is preferred)
3. Install the latest Firebird/PostgreSQL server:
```
sudo apt-get install firebird3.0-server
sudo apt-get install firebird-dev

sudo apt-get install postgres-client
```
