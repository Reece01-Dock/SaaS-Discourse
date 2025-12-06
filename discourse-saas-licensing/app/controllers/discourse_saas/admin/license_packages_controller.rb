# frozen_string_literal: true

module ::DiscourseSaas
  module Admin
    class LicensePackagesController < ::Admin::AdminController
      requires_plugin ::DiscourseSaas::PLUGIN_NAME

      def index
        render_serialized(DiscourseSaas::LicensePackage.all, LicensePackageSerializer)
      end

      def create
        package = DiscourseSaas::LicensePackage.create!(package_params)
        render_serialized(package, LicensePackageSerializer)
      end

      def update
        package = DiscourseSaas::LicensePackage.find(params[:id])
        package.update!(package_params)
        render_serialized(package, LicensePackageSerializer)
      end

      def destroy
        package = DiscourseSaas::LicensePackage.find(params[:id])
        package.destroy!
        render json: success_json
      end

      private

      def package_params
        params.require(:license_package).permit(
          :name,
          :price,
          :duration_days,
          :seats,
          :group_id,
          :is_org_license
        )
      end
    end
  end
end
