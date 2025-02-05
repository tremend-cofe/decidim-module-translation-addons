# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslationAddons
    module Admin
      module Reports
        module Filterable
          extend ActiveSupport::Concern

          included do
            include Decidim::Admin::Filterable

            private

            def base_query
              collection
            end

            def filters
              [
                :decidim_resource_type_eq,
                :locale_eq
              ]
            end

            def filters_with_values
              {
                decidim_resource_type_eq: reported_resource_type,
                locale_eq: available_locale

              }
            end

            def dynamically_translated_filters
              [:decidim_resource_type_eq,
               :locale_eq]
            end

            def translated_decidim_resource_type_eq(value)
              value.constantize.name.demodulize
            end

            def translated_locale_eq(value)
              value.capitalize
            end

            def search_field_predicate
              :field_name_cont
            end

            def reported_resource_type
              collection.pluck(:decidim_resource_type).uniq.sort
            end

            def available_locale
              current_organization.available_locales
            end

            def extra_allowed_params
              [:per_page]
            end
          end
        end
      end
    end
  end
end
