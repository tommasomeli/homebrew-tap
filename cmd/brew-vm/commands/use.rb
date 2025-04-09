#!/usr/bin/env ruby

# Implementation of the "use" command

# Only require the main module if it's not already defined
if !defined?(BrewVM)
  begin
    require_relative "../brew-vm"
  rescue LoadError
    # Try to find the brew-vm script relative to this file's location
    brew_vm_script = File.expand_path("../../brew-vm", __FILE__)
    if File.exist?(brew_vm_script)
      require brew_vm_script
    else
      # Provide minimal definitions for standalone use
      module BrewVM
        def self.ohai(message)
          puts "\033[1;34m==>\033[0m \033[1m#{message}\033[0m"
        end
        
        def self.odie(message)
          puts "\033[1;31mError:\033[0m #{message}"
          exit 1
        end
      end
    end
  end
end

module BrewVM
  module Commands
    module Use
      module_function

      def run(args)
        if args.include?("--help") || args.empty?
          show_help
          return
        end

        formula = args[0]
        version = args[1]

        # Enforce the correct syntax
        if formula.nil? || version.nil?
          BrewVM.odie "Usage: brew-vm use <formula> <version>"
        end

        # Check if the user tried to use the @ syntax and provide guidance
        if formula.include?("@")
          BrewVM.odie "Error: The syntax 'brew-vm use #{formula}' is not supported.\nPlease use: brew-vm use #{formula.split('@')[0]} #{formula.split('@')[1]}"
        end

        # Construct the target formula name
        base_formula = formula
        target_formula = "#{formula}@#{version}"

        # Check if the target formula is installed
        unless system("brew list --formula | grep -q \"^#{target_formula}$\"")
          BrewVM.odie "Formula '#{target_formula}' is not installed.\nYou may install it with:\n  brew install #{target_formula}"
        end

        # Check if base formula exists, create it if needed
        base_formula_exists = system("brew list --formula | grep -q \"^#{base_formula}$\"")
        if !base_formula_exists
          BrewVM.ohai "Base formula '#{base_formula}' not found. Creating a link to #{target_formula}..."
          # Try to create a symlink for the base formula
          system("brew link --force --overwrite #{target_formula}")
        end

        # Path to the formula bin
        formula_bin_dir = `brew --prefix #{target_formula}`.chomp + "/bin"

        # Perform the action
        if Dir.exist?(formula_bin_dir)
          # Create a temporary setup script
          temp_file = "/tmp/brew_vm_#{base_formula}_#{version}_#{Time.now.to_i}.sh"
          
          # Create the startup script for the new shell
          File.write(temp_file, <<~SCRIPT)
            #!/bin/bash

            # Add the selected formula to PATH
            export PATH="#{formula_bin_dir}:$PATH"

            # Update the prompt to show the active formula version
            if [[ -n $PS1 ]]; then
                PS1="(#{base_formula}@#{version}) $PS1"
            fi

            # Welcome message
            echo ""
            echo "🚀 Now using #{base_formula} #{version}"
            echo ""
            # Check the version of the formula to confirm it's working
            if command -v #{base_formula} &> /dev/null; then
                echo "Version information:"
                #{base_formula} --version 2>/dev/null || echo "No version information available"
            fi
            echo ""
            echo "Type 'exit' to return to the normal shell."
            echo ""

            # Execute the user's shell
            exec $(basename $SHELL)
          SCRIPT
          
          # Make it executable
          system("chmod +x #{temp_file}")
          
          BrewVM.ohai "Starting new shell with #{base_formula} #{version}..."
          puts ""
          
          # Launch the new shell
          exec temp_file
        else
          BrewVM.odie "Error: binary directory not found: #{formula_bin_dir}"
        end
      end

      def show_help
        puts <<~EOS
          Usage: brew-vm use <formula> <version>
          
          Start a new shell with the specified formula version in PATH.
          
          Example: brew-vm use python 3.11
          
          Type 'exit' to return to the normal shell.
        EOS
      end
    end
  end
end 