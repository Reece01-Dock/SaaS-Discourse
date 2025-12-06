# frozen_string_literal: true

module ::Jobs
  class LicenseExpirationJob < ::Jobs::Scheduled
    every 1.day

    def execute(_args)
      return unless SiteSetting.license_enabled

      DiscourseSaas::Purchase.expired.where(active: true).find_each do |purchase|
        purchase.expire!
      end
    end
  end
end
