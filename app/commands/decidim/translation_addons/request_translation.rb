# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class RequestTranslation < Decidim::Command
      def initialize(report, current_user)
        @report = report
        @current_user = current_user
      end

      def call
        default_locale = report.resource.respond_to?(:organization) ? report.resource.organization.default_locale.to_s : Decidim.available_locales.first.to_s
        if @report.blank? || @current_user.blank? || @report.resource[@report.field_name][@report.locale].present? || @report.resource[@report.field_name][default_locale].blank?
          return broadcast(:invalid)
        end

        request_translation
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :report, :current_user

      def request_translation
        Decidim.traceability.perform_action!(
          :request_translation,
          @report,
          @current_user,
          resource_type: @report.resource.class.name, resource_id: @report.resource.id, field: @report.field_name, locale: @report.locale
        ) do
          report.auto_translation_retry_count += 1
          report.translation_last_retry_on = Time.current
          report.save!
          source_locale = report.resource.respond_to?(:organization) ? report.resource.organization.default_locale.to_s : Decidim.available_locales.first.to_s
          Decidim::MachineTranslationFieldsJob.perform_later(
            report.resource,
            report.field_name,
            report.resource[report.resource.field_name][source_locale],
            report.locale,
            source_locale
          )
          report
        end
      end
    end
  end
end
