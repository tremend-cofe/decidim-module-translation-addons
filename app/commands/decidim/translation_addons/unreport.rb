# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class Unreport < Decidim::Command
      def initialize(report, resource_instance, current_user)
        @report = report
        @current_user = current_user
      end

      def call
        return broadcast(:invalid) if @report.blank? || @current_user.blank?

        unreport
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :report, :current_user

      def unreport
        Decidim.traceability.perform_action!(
          :unreport,
          @report,
          @current_user,
          resource_type: @report.resource.class.name, resource_id: @report.resource.id, field: @report.field_name, locale: @report.locale
        ) do
          @report.destroy!
        end
      end
    end
  end
end
