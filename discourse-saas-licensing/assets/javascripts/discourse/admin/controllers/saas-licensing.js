import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import bootbox from "bootbox";

export default class SaasLicensingController extends Controller {
  newPackage = {
    name: "",
    price: 0,
    duration_days: 30,
    seats: 1,
    group_id: null,
    is_org_license: false,
  };

  @action
  createPackage() {
    ajax("/saas/admin/license_packages", {
      type: "POST",
      data: { license_package: this.newPackage },
    })
      .then((response) => {
        const pkg =
          response.license_package || response.license_packages || response;
        this.model.packages.pushObject(pkg);
        this.set("newPackage", {
          name: "",
          price: 0,
          duration_days: 30,
          seats: 1,
          group_id: null,
          is_org_license: false,
        });
      })
      .catch(popupAjaxError);
  }

  @action
  updatePackage(pkg) {
    ajax(`/saas/admin/license_packages/${pkg.id}`, {
      type: "PUT",
      data: { license_package: pkg },
    }).catch(popupAjaxError);
  }

  @action
  deletePackage(pkg) {
    bootbox.confirm(I18n.t("admin.users.delete_user_confirm"), (result) => {
      if (!result) {
        return;
      }
      ajax(`/saas/admin/license_packages/${pkg.id}`, {
        type: "DELETE",
      })
        .then(() => {
          this.model.packages.removeObject(pkg);
        })
        .catch(popupAjaxError);
    });
  }

  @action
  inviteMember(org, emailOrUsername) {
    ajax(`/saas/admin/organisations/${org.id}/invite`, {
      type: "POST",
      data: { email: emailOrUsername, username: emailOrUsername },
    })
      .then(() => this._reloadOrgs())
      .catch(popupAjaxError);
  }

  @action
  removeMember(org, member) {
    ajax(`/saas/admin/organisations/${org.id}/member/${member.user_id}`, {
      type: "DELETE",
    })
      .then(() => this._reloadOrgs())
      .catch(popupAjaxError);
  }

  _reloadOrgs() {
    ajax("/saas/admin/organisations")
      .then((orgs) => {
        this.set(
          "model.organisations",
          orgs.organisations || orgs.organisation || orgs
        );
      })
      .catch(popupAjaxError);
  }
}
