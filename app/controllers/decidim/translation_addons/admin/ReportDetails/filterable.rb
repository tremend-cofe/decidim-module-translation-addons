# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslationAddons
    module Admin
      module ReportDetails
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
                :reason_eq,
                :report_locale_eq
              ]
            end

            def filters_with_values
              {
                reason_eq: report_reasons,
                report_locale_eq: available_locales
              }
            end

            def dynamically_translated_filters
              [:reason_eq,
               :report_locale_eq]
            end

            def search_field_predicate
              :report_field_name_cont
            end

            def translated_report_locale_eq(value)
              value.capitalize
            end

            def translated_reason_eq(value)
              value.capitalize
            end

            def report_reasons
              Decidim::TranslationAddons::Report::REASONS
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
