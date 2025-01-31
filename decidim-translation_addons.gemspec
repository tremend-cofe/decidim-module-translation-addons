# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/translation_addons/version"

Gem::Specification.new do |s|
  s.version = Decidim::TranslationAddons.version
  s.authors = ["Alexandru-Emil Lupu", "Robert Luca", "Andra Panaite"]
  s.email = ["contact@alecslupu.ro"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = "~> 3.2"

  s.name = "decidim-translation_addons"
  s.summary = "A decidim translation_addons module"
  s.description = "Translation utilities for Decidim."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ LICENSE-AGPLv3.txt Rakefile README.md))
    end
  end

  s.add_dependency "decidim-admin", Decidim::TranslationAddons.version
  s.add_dependency "decidim-core", Decidim::TranslationAddons.version
  s.add_dependency "deface", ">= 1.9"
  s.add_development_dependency "decidim-dev"
end
