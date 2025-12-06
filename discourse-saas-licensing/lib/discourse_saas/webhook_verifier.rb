# frozen_string_literal: true

module ::DiscourseSaas
  class WebhookVerifier
    HEADER_KEYS = ["X-SaaS-Signature", "Stripe-Signature"].freeze

    def self.valid?(payload:, signature_header:)
      secret = SiteSetting.stripe_secret_key.presence
      return true if secret.blank? # allow if not configured

      signature = signature_header.to_s
      return false if signature.blank?

      expected = OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
      ActiveSupport::SecurityUtils.secure_compare(expected, signature)
    end

    def self.extract_signature(request)
      HEADER_KEYS.each do |key|
        header = request.headers[key]
        return header if header.present?
      end
      nil
    end
  end
end
