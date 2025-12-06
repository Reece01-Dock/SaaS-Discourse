# frozen_string_literal: true

module ::DiscourseSaas
  class LicensePackageSerializer < ApplicationSerializer
    attributes :id, :name, :price, :duration_days, :seats, :group_id, :is_org_license
  end
end
