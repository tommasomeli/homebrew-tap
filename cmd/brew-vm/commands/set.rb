#!/usr/bin/env ruby

# Implementation of the "set" command (formerly "switch")

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
    module Set
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
          BrewVM.odie "Usage: brew-vm set <formula> <version>"
        end

        # Check if the user tried to use the @ syntax and provide guidance
        if formula.include?("@")
          BrewVM.odie "Error: The syntax 'brew-vm set #{formula}' is not supported.\nPlease use: brew-vm set #{formula.split('@')[0]} #{formula.split('@')[1]}"
        end

        # Construct the target formula name
        base_formula = formula
        target_formula = "#{formula}@#{version}"

        # Check if the target formula is installed
        unless system("brew list --formula | grep -q \"^#{target_formula}$\"")
          # Check if there are any versioned formulas available
          available_versions = `brew list --formula | grep "^#{base_formula}@"`.strip
          
          if available_versions.empty?
            BrewVM.odie "No versioned formulas for '#{base_formula}' are installed."
          else
            BrewVM.odie <<~EOS
              Formula '#{target_formula}' is not installed.
              
              Available versions installed:
              #{available_versions}
              
              You may install it with:
                brew install #{target_formula}
            EOS
          end
        end

        # Check if base formula exists
        base_formula_exists = system("brew list --formula | grep -q \"^#{base_formula}$\"")
        
        # Setting version as default
        BrewVM.ohai "Setting #{base_formula} default to version #{version} globally..."
        
        if base_formula_exists
          system "brew", "unlink", base_formula, out: File::NULL, err: File::NULL
        else
          BrewVM.ohai "Base formula '#{base_formula}' not found. Creating it as a link to #{target_formula}..."
        end
        
        system "brew", "unlink", target_formula, out: File::NULL, err: File::NULL
        system "brew", "link", "--force", "--overwrite", target_formula
        
        # Show confirmation
        BrewVM.ohai "Successfully set #{base_formula} #{version} as the system default"
      end

      def show_help
        puts <<~EOS
          Usage: brew-vm set <formula> <version>
          
          Set a specific version of a formula as the system default.
          
          Example: brew-vm set python 3.11
        EOS
      end
    end
  end
end 