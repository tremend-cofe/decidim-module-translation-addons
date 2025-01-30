# frozen_string_literal: true

require "decidim/translation_addons/admin"
require "decidim/translation_addons/engine"
require "decidim/translation_addons/admin_engine"

module Decidim
  # This namespace holds the logic of the `TranslationAddons` component. This component
  # allows users to create translation_addons in a participatory space.
  module TranslationAddons
    include ActiveSupport::Configurable

    config_accessor :reportable_resources do
      %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Debates::Debate
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Assembly
        Decidim::Conference
        Decidim::Initiative
        Decidim::ParticipatoryProcess
      )
    end

    config_accessor :deface_enabled do
      ENV.fetch("DEFACE_ENABLED", nil) == "true" || Rails.env.test?
    end
  end
end
