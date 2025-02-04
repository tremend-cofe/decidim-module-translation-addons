# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class CreateReport < Decidim::Command
      def initialize(form, resource_instance, current_user)
        @resource_instance = resource_instance
        @field = form.field
        @locale = form.locale
        @reason = form.reason
        @current_user = current_user
        @fix_suggestion = form.detail
      end

      def call
        return broadcast(:invalid) unless [resource_instance, field, locale, current_user, reason].all?
        if @reason == "missing" && (@resource_instance[@field][@locale].present? || @resource_instance[@field].dig("machine_translations", @locale).present?)
          return broadcast(:not_missing)
        end

        create_report
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :field, :locale, :current_user, :reason, :fix_suggestion

      def create_report
        @report = Decidim.traceability.perform_action!(
          :create,
          Decidim::TranslationAddons::Report,
          @current_user,
          visibility: "public-only"
        ) do
          report = Decidim::TranslationAddons::Report.where(resource: resource_instance, field_name: field, locale:).first_or_create

          report.details.create!(decidim_user_id: current_user.id, reason:, fix_suggestion:)
          report.reload
        end
      end
    end
  end
end
