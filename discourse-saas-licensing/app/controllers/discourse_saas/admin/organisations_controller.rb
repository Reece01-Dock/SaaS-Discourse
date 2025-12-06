# frozen_string_literal: true

module ::DiscourseSaas
  module Admin
    class OrganisationsController < ::Admin::AdminController
      requires_plugin ::DiscourseSaas::PLUGIN_NAME

      def index
        render_serialized(DiscourseSaas::Organisation.all, OrganisationSerializer)
      end

      def show
        org = DiscourseSaas::Organisation.find(params[:id])
        render_serialized(org, OrganisationSerializer)
      end

      def invite
        org = DiscourseSaas::Organisation.find(params[:id])
        target = find_or_create_user(params[:email], params[:username])
        org.add_member!(target)

        render json: success_json.merge(seats_used: org.seats_used, seats_total: org.seats_total)
      end

      def remove_member
        org = DiscourseSaas::Organisation.find(params[:id])
        user = User.find(params[:user_id])
        org.remove_member!(user)
        render json: success_json.merge(seats_used: org.seats_used, seats_total: org.seats_total)
      end

      private

      def find_or_create_user(email, username)
        user =
          if username.present?
            User.find_by(username: username) || User.find_by_email(email)
          elsif email.present?
            User.find_by_email(email)
          end

        return user if user.present?

        raise Discourse::InvalidParameters.new(:email) if email.blank?

        suggested_username =
          username.presence || UserNameSuggester.sanitize_username(email.split("@").first)

        created =
          User.create!(
            name: email.split("@").first,
            email: email,
            username: suggested_username,
            staged: true,
            active: true,
            approved: true
          )
        Jobs.enqueue(:send_system_message, user_id: created.id, message_type: "account_created")
        created
      end
    end
  end
end
