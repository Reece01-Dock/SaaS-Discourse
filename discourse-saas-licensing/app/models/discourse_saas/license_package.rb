# frozen_string_literal: true

module ::DiscourseSaas
  class LicensePackage < ActiveRecord::Base
    self.table_name = "discourse_saas_license_packages"

    belongs_to :group
    has_many :purchases, class_name: "DiscourseSaas::Purchase", dependent: :destroy

    validates :name, :price, :duration_days, presence: true
    validates :duration_days, :seats, numericality: { greater_than_or_equal_to: 0 }

    def org_license?
      is_org_license
    end
  end
end
