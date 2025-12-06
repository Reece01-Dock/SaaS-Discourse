# frozen_string_literal: true

module ::DiscourseSaas
  class WebhooksController < ::ApplicationController
    requires_plugin ::DiscourseSaas::PLUGIN_NAME
    skip_before_action :verify_authenticity_token
    skip_before_action :preload_json

    def purchases
      payload = request.raw_post
      signature = DiscourseSaas::WebhookVerifier.extract_signature(request)
      unless DiscourseSaas::WebhookVerifier.valid?(payload: payload, signature_header: signature)
        raise Discourse::InvalidAccess.new
      end

      event = JSON.parse(payload) rescue {}
      object = event.dig("data", "object") || event
      package_id = object.dig("metadata", "package_id") || params[:package_id]
      user_id = object.dig("metadata", "user_id") || params[:user_id]
      external_id = event["id"] || object["id"] || SecureRandom.hex(10)

      package = DiscourseSaas::LicensePackage.find(package_id)
      purchaser = User.find(user_id)

      service = DiscourseSaas::LicensingService.new(package: package, purchaser: purchaser)
      purchase = service.create_purchase_from_webhook(external_id: external_id)

      render json: { status: "ok", purchase_id: purchase.id }
    rescue StandardError => e
      render json: { error: e.message }, status: 422
    end
  end
end
