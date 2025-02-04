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
           allow! if permission_action.subject == :report && (permission_action.action == :read || permission_action.action == :unreport || permission_action.action == :create || permission_action.action == :update)
           allow! if permission_action.subject == :report_details && (permission_action.action == :create || permission_action.action == :unreport ||permission_action.action == :read)
          else
            allow! if permission_action.subject == :report && permission_action.action == :create
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
