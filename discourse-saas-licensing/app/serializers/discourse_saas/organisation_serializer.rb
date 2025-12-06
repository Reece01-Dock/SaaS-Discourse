# frozen_string_literal: true

module ::DiscourseSaas
  class OrganisationSerializer < ApplicationSerializer
    attributes :id,
               :name,
               :owner_id,
               :purchase_id,
               :group_id,
               :seats_total,
               :seats_used,
               :active

    has_one :group, serializer: BasicGroupSerializer, embed: :objects
    has_many :organisation_members, serializer: OrganisationMemberSerializer, embed: :objects
  end
end
