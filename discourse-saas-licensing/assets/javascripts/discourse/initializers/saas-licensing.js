import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "saas-licensing-admin-route",

  initialize() {
    withPluginApi("0.8.7", (api) => {
      api.addAdminRoute("saas_licensing.title", "/saas/licensing");
    });
  },
};
