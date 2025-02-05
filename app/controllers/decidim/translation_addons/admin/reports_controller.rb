# frozen_string_literal: true

module Decidim
  module TranslationAddons
    module Admin
      # Controller used to manage translation reports for the current
      # organization
      class ReportsController < Decidim::TranslationAddons::Admin::ApplicationController
        helper Decidim::PaginateHelper
        helper Decidim::ResourceHelper
        include Decidim::TranslationAddons::Admin::Reports::Filterable

        layout "decidim/admin/global_moderations"
        before_action :set_translation_breadcrumb_item

        def index
          enforce_permission_to :read, :report

          @reports = filtered_collection
        end

        def unreport
          enforce_permission_to :unreport, :report

          report = collection.find params[:id]
          Decidim::TranslationAddons::Unreport.call(report, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("unreport.success", scope: "decidim.admin")
              redirect_to reports_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("unreport.invalid", scope: "decidim.admin")
              redirect_to reports_path
            end
          end
        end

        def request_translation
          enforce_permission_to :read, :report

          report = collection.find params[:id]
          Decidim::TranslationAddons::RequestTranslation.call(report, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("translation_request.success", scope: "decidim.admin")
              redirect_to reports_path
            end

            on(:not_missing) do
              flash[:alert] = I18n.t("decidim.shared.notification_messages.not_missing")
              redirect_to reports_path
            end

            on(:missing_default_locale) do
              flash[:alert] = I18n.t("translation_request.missing_default_locale", scope: "decidim.admin")
              redirect_to reports_path
            end

            on(:missing_source_locale) do
              flash[:alert] = I18n.t("translation_request.missing_source_locale", scope: "decidim.admin")
              redirect_to reports_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("translation_request.invalid", scope: "decidim.admin")
              redirect_to reports_path
            end
          end
        end

        def collection
          @collection ||= Report.order(id: :desc)
        end

        def reports
          @reports ||= filtered_collection
        end

        def set_translation_breadcrumb_item
          controller_breadcrumb_items << {
            label: t("decidim.admin.reports.page_title"),
            url: decidim_admin_translation_addons.root_path,
            active: true
          }
        end
      end
    end
  end
end
