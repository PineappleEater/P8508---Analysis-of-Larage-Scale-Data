#!/usr/bin/env python3
"""
BRFSS Data Download Script
==========================
Downloads and extracts CDC BRFSS data files (2003-2015) for the final project.

Usage:
    python download_brfss.py

Note: 2010 is included in download but will be excluded during analysis
      (it's the "washout period" as defined in the paper).
"""

import os
import zipfile
import urllib.request
import ssl

# Create SSL context to handle certificate issues
ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

# Define paths
PROJECT_DIR = "/home/liang/desktop/P8508---Analysis-of-Larage-Scale-Data/final project"
RAW_DATA_DIR = os.path.join(PROJECT_DIR, "data", "raw")

# Create directories if they don't exist
os.makedirs(RAW_DATA_DIR, exist_ok=True)

# CDC BRFSS download URLs
# Note: File naming convention changed in 2011
#   2003-2010: CDBRFSXX.XPT
#   2011+: LLCPXXXX.XPT

BRFSS_URLS = {
    2003: "https://www.cdc.gov/brfss/annual_data/2003/files/CDBRFS03XPT.zip",
    2004: "https://www.cdc.gov/brfss/annual_data/2004/files/CDBRFS04XPT.zip",
    2005: "https://www.cdc.gov/brfss/annual_data/2005/files/CDBRFS05XPT.zip",
    2006: "https://www.cdc.gov/brfss/annual_data/2006/files/CDBRFS06XPT.zip",
    2007: "https://www.cdc.gov/brfss/annual_data/2007/files/CDBRFS07XPT.zip",
    2008: "https://www.cdc.gov/brfss/annual_data/2008/files/CDBRFS08XPT.zip",
    2009: "https://www.cdc.gov/brfss/annual_data/2009/files/CDBRFS09XPT.zip",
    2010: "https://www.cdc.gov/brfss/annual_data/2010/files/CDBRFS10XPT.zip",  # Washout period
    2011: "https://www.cdc.gov/brfss/annual_data/2011/files/LLCP2011XPT.zip",
    2012: "https://www.cdc.gov/brfss/annual_data/2012/files/LLCP2012XPT.zip",
    2013: "https://www.cdc.gov/brfss/annual_data/2013/files/LLCP2013XPT.zip",
    2014: "https://www.cdc.gov/brfss/annual_data/2014/files/LLCP2014XPT.zip",
    2015: "https://www.cdc.gov/brfss/annual_data/2015/files/LLCP2015XPT.zip",
}


def download_file(url, dest_path):
    """Download a file from URL to destination path."""
    print(f"  Downloading: {url}")
    try:
        # Try with SSL verification first
        urllib.request.urlretrieve(url, dest_path)
    except Exception as e:
        print(f"  Warning: SSL error, retrying without verification...")
        # Retry without SSL verification
        request = urllib.request.Request(url)
        with urllib.request.urlopen(request, context=ssl_context) as response:
            with open(dest_path, 'wb') as f:
                f.write(response.read())
    print(f"  Saved to: {dest_path}")


def extract_zip(zip_path, extract_dir):
    """Extract a zip file to the specified directory."""
    print(f"  Extracting: {zip_path}")
    with zipfile.ZipFile(zip_path, 'r') as zip_ref:
        zip_ref.extractall(extract_dir)
    print(f"  Extracted to: {extract_dir}")


def main():
    print("=" * 60)
    print("BRFSS Data Download Script")
    print("=" * 60)
    print(f"Target directory: {RAW_DATA_DIR}")
    print()
    
    # Download and extract each year
    for year, url in BRFSS_URLS.items():
        print(f"\n[{year}] Processing...")
        
        # Define file paths
        zip_filename = os.path.basename(url)
        zip_path = os.path.join(RAW_DATA_DIR, zip_filename)
        
        # Check if XPT file already exists
        if year <= 2010:
            xpt_filename = f"CDBRFS{str(year)[2:]}.XPT"
        else:
            xpt_filename = f"LLCP{year}.XPT"
        
        xpt_path = os.path.join(RAW_DATA_DIR, xpt_filename)
        
        # Also check for lowercase version
        xpt_path_lower = os.path.join(RAW_DATA_DIR, xpt_filename.lower())
        
        if os.path.exists(xpt_path) or os.path.exists(xpt_path_lower):
            print(f"  Already exists: {xpt_filename}, skipping...")
            continue
        
        # Download
        try:
            download_file(url, zip_path)
        except Exception as e:
            print(f"  ERROR downloading {year}: {e}")
            continue
        
        # Extract
        try:
            extract_zip(zip_path, RAW_DATA_DIR)
        except Exception as e:
            print(f"  ERROR extracting {year}: {e}")
            continue
        
        # Remove zip file to save space
        os.remove(zip_path)
        print(f"  Removed zip file: {zip_filename}")
    
    print("\n" + "=" * 60)
    print("Download complete!")
    print("=" * 60)
    
    # List downloaded files
    print("\nDownloaded files:")
    for f in sorted(os.listdir(RAW_DATA_DIR)):
        if f.upper().endswith('.XPT'):
            size_mb = os.path.getsize(os.path.join(RAW_DATA_DIR, f)) / (1024 * 1024)
            print(f"  {f} ({size_mb:.1f} MB)")
    
    print("\n" + "=" * 60)
    print("WHY IS 2010 INCLUDED BUT EXCLUDED FROM ANALYSIS?")
    print("=" * 60)
    print("""
The paper (Valvi et al. 2019) defines 2010 as a "washout period" because:

1. METHODOLOGY CHANGE: In 2011, BRFSS changed from landline-only 
   to landline + cell phone sampling. Data from before and after 
   this change are not directly comparable.

2. EARLY ADOPTERS: 5 states + DC started Medicaid expansion in 
   2010 under ACA waivers, before the main 2014 implementation.

3. CLEAN COMPARISON: By excluding 2010, we get a cleaner 
   pre-period (2003-2009) and post-period (2011-2015).

The paper explicitly states this in Section 2.3:
"...we considered the year 2010 as the washout period..."

We download 2010 for completeness, but the analysis code 
(proc.do) will exclude it.
""")
    
    print("\nNext steps:")
    print("1. Open Stata")
    print("2. Run: do proc.do")
    print("3. Run: do analysis.do")


if __name__ == "__main__":
    main()
