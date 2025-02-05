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
                :reason_eq
              ]
            end

            def filters_with_values
              {
                reason_eq: report_reasons
              }
            end

            def dynamically_translated_filters
              [:reason_eq]
            end

            def search_field_predicate
              :decidim_user_id_eq
            end

            def translated_reason_eq(value)
              value.capitalize
            end

            def report_reasons
              Decidim::TranslationAddons::Report::REASONS
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
