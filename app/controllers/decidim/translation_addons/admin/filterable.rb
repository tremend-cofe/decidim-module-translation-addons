# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module TranslationAddons
    module Admin
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
                :reports_reason_eq
            ]
          end

          def filters_with_values
            {
                reports_reason_eq: report_reasons
            }
          end

          def dynamically_translated_filters
            []
          end

          def search_field_predicate

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
