import AdminRoute from "discourse/routes/admin-route";
import { ajax } from "discourse/lib/ajax";

export default class SaasLicensingRoute extends AdminRoute {
  model() {
    return Promise.all([
      ajax("/saas/admin/license_packages"),
      ajax("/saas/admin/organisations"),
    ]).then(([packages, organisations]) => {
      return {
        packages: packages.license_packages || packages.license_package || packages,
        organisations:
          organisations.organisations || organisations.organisation || organisations,
      };
    });
  }
}
