# frozen_string_literal: true

module ::DiscourseSaas
  class Purchase < ActiveRecord::Base
    self.table_name = "discourse_saas_purchases"

    belongs_to :user
    belongs_to :license_package, class_name: "DiscourseSaas::LicensePackage"
    has_one :organisation, class_name: "DiscourseSaas::Organisation", dependent: :destroy

    validates :external_id, :purchased_at, :expires_at, presence: true

    scope :active, -> { where(active: true).where("expires_at > ?", Time.zone.now) }
    scope :expired, -> { where("expires_at <= ?", Time.zone.now) }

    def expire!
      transaction do
        update!(active: false)
        remove_groups!
      end
    end

    def remove_groups!
      if license_package&.group_id && user
        GroupUser.where(group_id: license_package.group_id, user_id: user.id).destroy_all
      end

      if organisation
        organisation.deactivate!
      end
    end
  end
end
