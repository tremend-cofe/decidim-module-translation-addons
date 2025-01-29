# frozen_string_literal: true

module Decidim
  # A form object to be used when public users want to report a translation for a resource.
  module TranslationAddons
    module Admin
      class AcceptTranslationForm < Decidim::Form
        mimic :report_detail

        attribute :field, String # Field that was reported
        attribute :detail, String # Fix suggestion from user
        attribute :reason, String # Reason of report
        attribute :field_translation, String # Value to be submitted
        attribute :locale, String # Current locale of the report
        attribute :resource_id, Integer #ID of the ReportDetail

        validates :field_translation, presence: true
      end
    end
  end
end
