#!/usr/bin/env python3
"""
Script to parse DEEP_LINK_BASE_URL from JSON config files and generate iOS build settings.
This script extracts custom URL scheme and associated domain from DEEP_LINK_BASE_URL.
"""

import json
import sys
import os

def parse_deep_link_base_url(deep_link_url):
    """Parse DEEP_LINK_BASE_URL and extract custom scheme and associated domain."""
    if deep_link_url.startswith("edulift://"):
        # Custom URL scheme
        custom_scheme = "edulift"
        associated_domain = ""
    elif deep_link_url.startswith("https://"):
        # HTTPS Universal Link
        # Extract host (with port if present)
        url_without_scheme = deep_link_url.removeprefix("https://").strip('/')
        associated_domain = f"applinks:{url_without_scheme}"
        # For Universal Links, we still need a custom scheme for the app
        # Use a fallback scheme based on the environment
        custom_scheme = "edulift"
    else:
        raise ValueError(f"Unsupported deep link URL format: {deep_link_url}")

    return custom_scheme, associated_domain

def main():
    if len(sys.argv) != 4:
        print("Usage: python3 parse_config.py <config_file_path> <output_xcconfig_path> <environment>")
        sys.exit(1)

    config_file_path = sys.argv[1]
    output_xcconfig_path = sys.argv[2]
    environment = sys.argv[3]

    if not os.path.exists(config_file_path):
        print(f"Error: Config file not found: {config_file_path}")
        sys.exit(1)

    try:
        # Read and parse JSON config
        with open(config_file_path, 'r') as f:
            config = json.load(f)

        deep_link_base_url = config.get('DEEP_LINK_BASE_URL', '')
        if not deep_link_base_url:
            print("Error: DEEP_LINK_BASE_URL not found in config file")
            sys.exit(1)

        # Parse the URL
        custom_scheme, associated_domain = parse_deep_link_base_url(deep_link_base_url)

        print(f"Environment: {environment}")
        print(f"DEEP_LINK_BASE_URL: {deep_link_base_url}")
        print(f"Custom URL Scheme: {custom_scheme}")
        print(f"Associated Domain: {associated_domain}")

        # Write to .xcconfig file
        with open(output_xcconfig_path, 'w') as f:
            f.write(f"// Auto-generated configuration for {environment}\n")
            f.write(f"// Generated from {config_file_path}\n\n")
            f.write(f"CUSTOM_URL_SCHEME = {custom_scheme}\n")
            f.write(f"ASSOCIATED_DOMAIN = {associated_domain}\n")

        print(f"Configuration written to: {output_xcconfig_path}")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()