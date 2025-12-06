# frozen_string_literal: true

module ::DiscourseSaas
  class LicensingService
    def initialize(package:, purchaser:, organisation: nil)
      @package = package
      @purchaser = purchaser
      @organisation = organisation
    end

    def create_purchase_from_webhook(external_id:, purchased_at: Time.zone.now)
      Purchase.transaction do
        purchase = Purchase.create!(
          user: @purchaser,
          license_package: @package,
          external_id: external_id,
          purchased_at: purchased_at,
          expires_at: purchased_at + @package.duration_days.days,
          active: true
        )

        if @package.group_id
          GroupUser.find_or_create_by!(group_id: @package.group_id, user_id: @purchaser.id)
        end

        if @package.is_org_license
          org = create_or_update_org(purchase)
          assign_org_owner(org)
        end

        purchase
      end
    end

    def create_or_update_org(purchase)
      Organisation.create!(
        name: "#{@purchaser.username}'s Org",
        owner: @purchaser,
        purchase: purchase,
        seats_total: @package.seats,
        seats_used: 0
      ).tap do |org|
        org.ensure_group!
      end
    end

    def assign_org_owner(org)
      org.add_member!(@purchaser, owner: true)
    end
  end
end
