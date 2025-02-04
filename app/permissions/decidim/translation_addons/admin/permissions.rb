# frozen_string_literal: true

module Decidim
  module TranslationAddons
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user&.admin?

          allow! if can_access?

          if user.admin?
            allow! if permission_action.subject == :report && [:read, :unreport, :create, :update].include?(permission_action.action)
            allow! if permission_action.subject == :report_details && [:read, :unreport, :create].include?(permission_action.action)
          elsif permission_action.subject == :report && permission_action.action == :create
            allow!
          end

          permission_action
        end

        def can_access?
          permission_action.subject == :translation_addons &&
            permission_action.action == :read
        end
      end
    end
  end
end
