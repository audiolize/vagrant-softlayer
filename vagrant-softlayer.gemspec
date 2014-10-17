$:.unshift File.expand_path("../lib", __FILE__)
require "vagrant-softlayer/version"

Gem::Specification.new do |spec|
  spec.name          = "vagrant-softlayer"
  spec.version       = VagrantPlugins::SoftLayer::VERSION
  spec.authors       = "Audiolize GmbH"
  spec.email         = ""
  spec.homepage      = "https://github.com/audiolize/vagrant-softlayer"
  spec.description   = "Enables Vagrant to manages SoftLayer CCI."
  spec.summary       = "Enables Vagrant to manages SoftLayer CCI."
  spec.license       = "MIT"

  # The following block of code determines the files that should be included
  # in the gem. It does this by reading all the files in the directory where
  # this gemspec is, and parsing out the ignored files from the gitignore.
  # Note that the entire gitignore(5) syntax is not supported, specifically
  # the "!" syntax, but it should mostly work correctly.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
  all_files.reject! { |file| [".", ".."].include?(File.basename(file)) }
  gitignore_path = File.join(root_path, ".gitignore")
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignore any directories, the gemspec only cares about files
    next true if File.directory?(file)

    # Ignore any paths that match anything in the gitignore. We do
    # two tests here:
    #
    #   - First, test to see if the entire path matches the gitignore.
    #   - Second, match if the basename does, this makes it so that things
    #     like '.DS_Store' will match sub-directories too (same behavior
    #     as git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
        File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  spec.files        = unignored_files
  spec.executables  = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files   = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_path = "lib"

  spec.add_dependency "softlayer_api", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "<2.99"
end
