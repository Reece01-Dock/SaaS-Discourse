# frozen_string_literal: true

module ::DiscourseSaas
  class LicensesController < ::ApplicationController
    requires_plugin ::DiscourseSaas::PLUGIN_NAME
    skip_before_action :verify_authenticity_token

    def user
      user = User.find(params[:id])
      purchases = DiscourseSaas::Purchase.active.where(user: user)
      render_json_dump(
        user: BasicUserSerializer.new(user, root: false).as_json,
        purchases: ActiveModel::Serializer::CollectionSerializer.new(
          purchases,
          serializer: PurchaseSerializer
        ),
        groups: user.groups.pluck(:name)
      )
    end

    def organisation
      org = DiscourseSaas::Organisation.find(params[:id])
      raise Discourse::InvalidAccess.new unless guardian.is_staff? || guardian.user == org.owner

      render_serialized(org, OrganisationSerializer)
    end

    def validate
      user = User.find_by(id: params[:user_id])
      org = DiscourseSaas::Organisation.find_by(id: params[:organisation_id])

      render json: {
        user_id: user&.id,
        active_user_licenses:
          user ? DiscourseSaas::Purchase.active.where(user: user).pluck(:license_package_id) : [],
        organisation_id: org&.id,
        organisation_active: org&.active?,
        seats: org ? { used: org.seats_used, total: org.seats_total } : nil,
        groups: user ? user.groups.pluck(:name) : [],
      }
    end
  end
end
