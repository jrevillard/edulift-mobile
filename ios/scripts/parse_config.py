#!/usr/bin/env python3
"""
Script to parse DEEP_LINK_BASE_URL from JSON config files and generate iOS build settings.
This script extracts custom URL scheme and associated domain from DEEP_LINK_BASE_URL.
"""

import json
import sys
import os

def parse_deep_link_config(config):
    """Parse deep link configuration and extract custom scheme and associated domains."""
    deep_link_base_url = config.get('DEEP_LINK_BASE_URL', '')
    custom_url_scheme = config.get('CUSTOM_URL_SCHEME', 'edulift')
    universal_links_enabled = config.get('UNIVERSAL_LINKS_ENABLED', False)

    # Always include custom scheme
    custom_scheme = custom_url_scheme

    # Build associated domains list based on configuration
    associated_domains = []

    if universal_links_enabled and deep_link_base_url.startswith("https://"):
        # Extract host (with port if present) for Universal Links
        url_without_scheme = deep_link_base_url.removeprefix("https://").strip('/')
        associated_domains.append(f"applinks:{url_without_scheme}")

    return custom_scheme, associated_domains

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

        # Parse the deep link configuration
        custom_scheme, associated_domains = parse_deep_link_config(config)

        print(f"Environment: {environment}")
        print(f"Custom URL Scheme: {custom_scheme}")
        print(f"Associated Domains: {associated_domains}")

        # Write to .xcconfig file
        with open(output_xcconfig_path, 'w') as f:
            f.write(f"// Auto-generated configuration for {environment}\n")
            f.write(f"// Generated from {config_file_path}\n\n")
            f.write(f"CUSTOM_URL_SCHEME = {custom_scheme}\n")

            # Write associated domains as space-separated list for Info.plist
            if associated_domains:
                f.write(f"ASSOCIATED_DOMAINS = {' '.join(associated_domains)}\n")
            else:
                f.write(f"ASSOCIATED_DOMAINS = \n")

        print(f"Configuration written to: {output_xcconfig_path}")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()