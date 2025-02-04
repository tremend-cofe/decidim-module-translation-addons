# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class AcceptDetail < Decidim::Command
      include Decidim::SanitizeHelper

      def initialize(form)
        @report_detail = Decidim::TranslationAddons::ReportDetail.find form.id
        @current_user = form.current_user
        @new_value = decidim_sanitize(form.field_translation)
      end

      def call
        return broadcast(:invalid) unless [report_detail, current_user, new_value].all?

        accept_detail
        broadcast(:ok)
      end

      private

      attr_reader :report_detail, :current_user, :new_value

      def accept_detail
        Decidim.traceability.perform_action!(
          :accept_detail,
          @report_detail,
          @current_user,
          @report_detail.log_attributes.merge({ action_user_id: @current_user_id, new_value: @new_value })
        ) do
          field_object = @report_detail.report.resource[@report_detail.report.field_name]
          field_object.merge!(@report_detail.report.locale => @new_value)
          if field_object.has_key?("machine_translations") && field_object["machine_translations"].has_key?(@report_detail.report.locale)
            field_object["machine_translations"].except!(@report_detail.report.locale)
          end
          @report_detail.report.resource.update_column @report_detail.report.field_name.to_sym, field_object # rubocop:disable Rails/SkipsModelValidations
          @report_detail.report.destroy
        end
      end
    end
  end
end
