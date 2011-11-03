# require all files here
require 'rbconfig'
require 'repoman/core'
require 'repoman/errors'
require 'repoman/git'
require 'repoman/actions'
require 'repoman/app'
require 'repoman/settings'
require 'repoman/repo'
require 'repoman/logger'


# Master namespace
module Repoman

  # Contents of the VERSION file
  #
  # Example format: 0.0.1
  #
  # @return [String] the contents of the version file in #.#.# format
  def self.version
    version_info_file = File.join(File.dirname(__FILE__), *%w[.. VERSION])
    File.open(version_info_file, "r") do |f|
      f.read.strip
    end
  end

  # Platform constants
  unless defined?(BasicGem::WINDOWS)
    WINDOWS = Config::CONFIG['host_os'] =~ /mswin|mingw/i
    CYGWIN = Config::CONFIG['host_os'] =~ /cygwin/i
  end

end

