# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class UnreportDetail < Decidim::Command
      def initialize(report_detail, current_user)
        @report_detail = report_detail
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) if @report_detail.blank? || @current_user.blank?

        unreport_detail
        broadcast(:ok)
      end

      private

      attr_reader :report_detail, :current_user

      def unreport_detail
        Decidim.traceability.perform_action!(
          :unreport_detail,
          @report_detail,
          @current_user,
          {
            report_id: @report_detail.report.id,
            resource_type: @report_detail.report.class.name,
            field_name: @report_detail.report.field_name,
            resource_id: @report_detail.report.id,
            locale: @report_detail.report.locale,
            fix_suggestion: @report_detail.fix_suggestion,
            reporting_user_id: @report_detail.decidim_user_id,
            action_user_id: @current_user_id

          }
        ) do
          @report_detail.destroy!
        end
      end
    end
  end
end
