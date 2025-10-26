# frozen_string_literal: true

# ------------------------------------------------------------------------------
#
#  This script configures the Xcode project for Flutter flavors.
#  It creates new build configurations for each flavor, duplicating the
#  existing Debug, Profile, and Release configurations.
#
#  Usage:
#  1. Ensure you have a Gemfile with 'xcodeproj' and 'colorize'.
#  2. Run `bundle install`.
#  3. Run this script from the project root: `bundle exec ruby scripts/setup_ios_flavors.rb`
#
# ------------------------------------------------------------------------------

require 'xcodeproj'
require 'colorize'

# ----------------------------------------
# Configuration
# ----------------------------------------

# Define your Flutter flavors here.
FLAVORS = %w[development staging e2e production].freeze

# Path to your Xcode project.
PROJECT_PATH = 'ios/Runner.xcodeproj'

# ----------------------------------------
# Main Script
# ----------------------------------------

puts 'Starting iOS flavor configuration script...'.yellow

# Open the Xcode project.
project = Xcodeproj::Project.open(PROJECT_PATH)

# Get the main Runner target.
target = project.targets.find { |t| t.name == 'Runner' }
unless target
  puts 'Error: Runner target not found.'.red
  exit 1
end

puts "Found target: #{target.name}".cyan

# --- Step 1: Create new build configurations from flavors ---
puts "\nProcessing build configurations...".yellow
base_configurations = {
  'Debug' => 'Debug',
  'Profile' => 'Profile',
  'Release' => 'Release'
}

FLAVORS.each do |flavor|
  base_configurations.each do |config_name, base_config_name|
    new_config_name = "#{config_name}-#{flavor}"

    # Find or create the new configuration for the project.
    if project.build_configurations.find { |c| c.name == new_config_name }
      puts "Configuration '#{new_config_name}' already exists for the project.".light_black
    else
      # Duplicate the base configuration (e.g., 'Debug') for the project.
      base_config = project.build_configurations.find { |c| c.name == base_config_name }
      new_config = project.new_configuration(new_config_name, base_config.type)
      new_config.build_settings.merge!(base_config.build_settings)
      puts "Created project configuration: '#{new_config_name}'".green
    end

    # Find or create the new configuration for the Runner target.
    if target.build_configurations.find { |c| c.name == new_config_name }
      puts "Configuration '#{new_config_name}' already exists for the target.".light_black
    else
      # Duplicate the base configuration for the target.
      base_config = target.build_configurations.find { |c| c.name == base_config_name }
      new_config = target.add_build_configuration(new_config_name, base_config.type)
      new_config.build_settings.merge!(base_config.build_settings)
      puts "Created target configuration: '#{new_config_name}'".green
    end
  end
end

# --- Step 2: Assign XCConfig files and fix SWIFT_VERSION ---
puts "\nAssigning XCConfig files and normalizing build settings...".yellow
target.build_configurations.each do |config|
  # Match configurations like 'Debug-development', 'Release-staging', etc.
  match = config.name.match(/^(Debug|Profile|Release)-(\w+)$/)
  next unless match

  config_type = match[1] # Debug, Profile, or Release
  flavor = match[2] # development, staging, etc.

  # Construct the path to the combined XCConfig file.
  xcconfig_path = "Flutter/#{config_type}-#{flavor}.xcconfig"
  xcconfig_file = project.files.find { |f| f.path == xcconfig_path }

  unless xcconfig_file
    puts "Warning: XCConfig file not found at '#{xcconfig_path}'. Please create it.".red
    next
  end

  # Assign the XCConfig file to the build configuration.
  config.base_configuration_reference = xcconfig_file
  puts "Assigned '#{xcconfig_path}' to '#{config.name}' configuration.".cyan

  # --- CRITICAL STEP: Fix SWIFT_VERSION conflict ---
  # By setting SWIFT_VERSION to '$(inherited)', we force Xcode
  # to use the value from the project level, which is what CocoaPods expects.
  # This prevents the "multiple swift versions" error.
  if config.build_settings['SWIFT_VERSION']
    config.build_settings['SWIFT_VERSION'] = '$(inherited)'
    puts "Normalized SWIFT_VERSION for '#{config.name}'.".cyan
  end
end

# --- Step 3: Save the project ---
project.save
puts "\nProject '#{PROJECT_PATH}' saved successfully.".green
puts 'Configuration complete. Please run `cd ios && pod install` now.'.yellow
