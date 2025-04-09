class BrewVm < Formula
  desc "Homebrew Version Manager - Tools for managing multiple versions of formulas"
  homepage "https://github.com/tommasomeli/homebrew-tap"
  url "https://github.com/tommasomeli/homebrew-tap/archive/refs/heads/main.tar.gz"
  version "0.1.0"
  license "MIT"
  
  depends_on "ruby"
  
  def install
    # Create needed directories
    libexec.mkpath
    (libexec/"commands").mkpath
    
    # Install the main script
    inreplace "cmd/brew-vm/brew-vm" do |s|
      s.gsub! "VERSION = \"0.1.0\"", "VERSION = \"#{version}\""
    end
    
    # Install the main script to libexec
    libexec.install "cmd/brew-vm/brew-vm"
    
    # Install the command files to libexec/commands
    (libexec/"commands").install Dir["cmd/brew-vm/commands/*.rb"]
    
    # Make the scripts executable
    chmod 0755, libexec/"brew-vm"
    
    # Create symlink in bin
    bin.install_symlink libexec/"brew-vm"
  end
  
  def caveats
    <<~EOS
      The Homebrew Version Manager has been installed.
      
      You can use the following commands:
        brew-vm use <formula> <version>
            Starts a new shell with the specified version in PATH
            Example: brew-vm use python 3.11
      
        brew-vm set <formula> <version>
            Sets a formula version as the system default
            Example: brew-vm set python 3.11
    EOS
  end
  
  test do
    # Test the installation by checking if the executable exists
    assert_predicate bin/"brew-vm", :executable?
    
    # Test if the help commands work
    system bin/"brew-vm", "--version"
    system bin/"brew-vm", "--help"
  end
end 