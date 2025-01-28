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
          @reports = filtered_collection
        end

        def unreport
          # enforce_permission_to :unreport, authorization_scope

          report = Decidim::TranslationAddons::Report.find params[:id]
          Decidim::TranslationAddons::Unreport.call(report, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
              redirect_to reports_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
              redirect_to reports_path
            end
          end
        end

        def request_translation
          report = Decidim::TranslationAddons::Report.find params[:id]
          Decidim::TranslationAddons::RequestTranslation.call(report, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
              redirect_to reports_path
            end

            on(:invalid) do
              flash[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
              redirect_to reports_path
            end
          end
        end

        def configure
          @report_details = Decidim::TranslationAddons::ReportDetail.where(decidim_translation_addons_report_id: params[:id])
        end

        def base_query_finder
          Decidim::TranslationAddons::Report.all
        end

        def collection
          @collection ||= Decidim::TranslationAddons::Report.all
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
