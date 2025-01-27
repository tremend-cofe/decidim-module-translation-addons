# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class Report < ApplicationRecord
      REASONS = %w(missing wrong).freeze
      belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
      has_many :details, foreign_key: "decidim_translation_addons_report_id", class_name: "Decidim::TranslationAddons::ReportDetail", dependent: :destroy
      validates :decidim_resource_id, uniqueness: { scope: [:decidim_resource_type, :field_name, :locale] }
    end
  end
end
