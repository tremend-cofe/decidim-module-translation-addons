# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_translation_addons: "#{base_path}/app/packs/entrypoints/decidim_translation_addons.js"
)
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/translation_addons/translation_addons")
