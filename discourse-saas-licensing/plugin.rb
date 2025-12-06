# frozen_string_literal: true

# name: discourse-saas-licensing
# about: Full SaaS licensing system with Stripe Checkout, organisation seats, and Discourse group enforcement
# version: 0.1.0
# authors: Codex
# url: https://example.com/discourse-saas-licensing

enabled_site_setting :license_enabled

register_asset "stylesheets/common/discourse-saas-licensing.scss", :common

after_initialize do
  module ::DiscourseSaas
    PLUGIN_NAME = "discourse-saas-licensing"
  end

  # Ensure we have our helper modules loaded
  require_relative "config/routes"
  require_relative "lib/discourse_saas/engine"
  require_relative "lib/discourse_saas/webhook_verifier"
  require_relative "lib/discourse_saas/licensing_service"
  require_relative "app/jobs/daily/license_expiration_job"

  # Mount engine routes
  Discourse::Application.routes.append do
    mount ::DiscourseSaas::Engine, at: "/saas"
  end

  %w[
    app/controllers/discourse_saas/licenses_controller
    app/controllers/discourse_saas/webhooks_controller
    app/controllers/discourse_saas/admin/license_packages_controller
    app/controllers/discourse_saas/admin/organisations_controller
    app/serializers/discourse_saas/license_package_serializer
    app/serializers/discourse_saas/purchase_serializer
    app/serializers/discourse_saas/organisation_serializer
    app/serializers/discourse_saas/organisation_member_serializer
  ].each { |path| require_relative path }
end
