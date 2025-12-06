# frozen_string_literal: true

module ::DiscourseSaas
  class PurchaseSerializer < ApplicationSerializer
    attributes :id,
               :user_id,
               :license_package_id,
               :external_id,
               :purchased_at,
               :expires_at,
               :active

    has_one :license_package, serializer: LicensePackageSerializer, embed: :objects
  end
end
