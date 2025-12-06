# frozen_string_literal: true

module ::DiscourseSaas
  class OrganisationMemberSerializer < ApplicationSerializer
    attributes :id, :user_id, :owner, :seated, :username, :name

    def username
      object.user.username
    end

    def name
      object.user.name
    end
  end
end
