# frozen_string_literal: true

module Decidim
  module TranslationAddons
    # This is the engine that runs on the public interface of `TranslationAddons`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::TranslationAddons::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resource :reports, only: [:index]
        root to: "reports#index"
      end

      initializer "decidim_translation_addons_admin.routing" do
        Decidim::Admin::Engine.routes do
          mount Decidim::TranslationAddons::AdminEngine, at: "/translation_addons", as: :decidim_admin_translation_addons
        end
      end

      initializer "decidim_translation_addons_admin.menu" do
        Decidim.menu :admin_global_moderation_menu do |menu|
          menu.add_item :translation_moderation,
                        "Test",
                        decidim_admin_translation_addons.root_path,
                        position: 1.3,
                        active: is_active_link?(decidim_admin_translation_addons.root_path)
        end
      end

      def load_seed
        nil
      end
    end
  end
end
