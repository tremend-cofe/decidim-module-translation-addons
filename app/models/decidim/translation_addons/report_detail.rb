# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class ReportDetail < ApplicationRecord
      belongs_to :report, foreign_key: "decidim_translation_addons_report_id", class_name: "Decidim::TranslationAddons::Report", touch: true
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      validates :decidim_translation_addons_report_id, presence: true
      validates :decidim_user_id, presence: true
      validates :reason, presence: true
      validates :decidim_translation_addons_report_id, uniqueness: { scope: [:decidim_user_id] }

      after_destroy :delete_parent

      def delete_parent
        report.destroy if report.details.none?
      end

      def log_attributes
        {
          resource_type: report.class.name,
          field_name: report.field_name,
          resource_id: report.id,
          locale: report.locale,
          }
      end
    end
  end
end
