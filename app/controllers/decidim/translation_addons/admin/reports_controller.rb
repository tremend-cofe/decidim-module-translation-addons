# frozen_string_literal: true

module Decidim
  module TranslationAddons
    module Admin
      # Controller used to manage translation reports for the current
      # organization
      class ReportsController < Decidim::TranslationAddons::Admin::ApplicationController
        include Decidim::PaginateHelper
        # include Decidim::Moderations::Admin::Filterable // To be implemented for Decidim::TranslationAddons::Admin::Filterable

        def index
          @reports = Decidim::TranslationAddons::Report.all
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
              flash.now[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
              redirect_to reports_path
            end
          end
        end
      end
    end
  end
end
