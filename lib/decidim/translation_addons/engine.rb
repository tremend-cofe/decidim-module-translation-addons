# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"

module Decidim
  module TranslationAddons
    # This is the engine that runs on the public interface of translation_addons.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::TranslationAddons

      routes do
        resource :translation_report, only: [:create], controller: "reports"
      end

      initializer "decidim_translation_addons.deface" do
        Rails.application.configure do
          config.deface.enabled = true
        end
      end

      initializer "decidim_translation_addons.add_cells_view_paths", before: "decidim_comments.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::TranslationAddons::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::TranslationAddons::Engine.root}/app/views") # for partials
      end

      initializer "decidim_translation_addons.routing" do
        Decidim::Core::Engine.routes do
          mount Decidim::TranslationAddons::Engine => "/translation_addons", :as => :translation_addons
        end
      end
    end
  end
end
