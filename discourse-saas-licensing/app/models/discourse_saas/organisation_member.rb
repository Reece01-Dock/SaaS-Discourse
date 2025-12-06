# frozen_string_literal: true

module ::DiscourseSaas
  class OrganisationMember < ActiveRecord::Base
    self.table_name = "discourse_saas_organisation_members"

    belongs_to :organisation, class_name: "DiscourseSaas::Organisation"
    belongs_to :user

    validates :organisation, :user, presence: true
  end
end
