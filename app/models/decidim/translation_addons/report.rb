# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class Report < ApplicationRecord
      REASONS = %w(missing wrong).freeze
      belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
      has_many :details, foreign_key: "decidim_translation_addons_report_id", class_name: "Decidim::TranslationAddons::ReportDetail", dependent: :destroy
      validates :decidim_resource_id, uniqueness: { scope: [:decidim_resource_type, :field_name, :locale] }

      def field_with_merged_machine_translations
        original = resource[field_name]
        machine_translations = original["machine_translations"] || {}
        # Merge machine translations into the original hash with conditional logic for key collisions
        merged = original.merge(machine_translations) do |_key, main_val, _machine_val|
          main_val # Keep the value from the main object when keys collide
        end
        # Remove the "machine_translations" key and empty keys from the result
        merged.except("machine_translations").reject { |_, value| value.nil? || value == "" }
      end
    end
  end
end
