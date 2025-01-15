require_relative "lib/decidim/translation_addons/version"

Gem::Specification.new do |spec|
  spec.name        = "decidim-translation_addons"
  spec.version     = Decidim::TranslationAddons::VERSION
  spec.authors     = ["robert"]
  spec.email       = ["robert.luca@publicissapient.com"]
  spec.homepage    = "TODO"
  spec.summary     = "TODO: Summary of Decidim::TranslationAddons."
  spec.description = "TODO: Description of Decidim::TranslationAddons."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.8.4"
end
