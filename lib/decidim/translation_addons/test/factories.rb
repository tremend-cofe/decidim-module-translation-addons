# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"

FactoryBot.define do
  factory :translation_addons_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :translation_addons).i18n_name }
    manifest_name :translation_addons
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end
