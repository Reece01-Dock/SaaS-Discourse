# frozen_string_literal: true

module ::DiscourseSaas
  class Organisation < ActiveRecord::Base
    self.table_name = "discourse_saas_organisations"

    belongs_to :owner, class_name: "User"
    belongs_to :purchase, class_name: "DiscourseSaas::Purchase"
    belongs_to :group, optional: true
    has_many :organisation_members, class_name: "DiscourseSaas::OrganisationMember", dependent: :destroy

    validates :name, presence: true

    def ensure_group!
      return group if group.present?

      generated = Group.create!(
        name: "org_#{name.parameterize}_#{SecureRandom.hex(4)}",
        visibility_level: Group.visibility_levels[:staff]
      )
      update!(group: generated)
      generated
    end

    def add_member!(user, owner: false)
      raise Discourse::InvalidAccess.new("org inactive") unless active?
      raise Discourse::InvalidParameters.new("No seats available") if seats_used >= seats_total && !member?(user)

      transaction do
        ensure_group!
        GroupUser.find_or_create_by!(group: group, user: user)

        org_member = organisation_members.find_or_initialize_by(user: user)
        org_member.owner = owner if owner
        org_member.save!

        increment!(:seats_used) unless org_member.seated?
        org_member.update!(seated: true)
        org_member
      end
    end

    def remove_member!(user)
      return unless member?(user)

      transaction do
        organisation_members.where(user: user).update_all(seated: false)
        decrement!(:seats_used) if seats_used.positive?
        GroupUser.where(group: group, user: user).destroy_all
      end
    end

    def member?(user)
      organisation_members.exists?(user: user, seated: true)
    end

    def deactivate!
      transaction do
        update!(active: false)
        organisation_members.each { |m| remove_member!(m.user) }
      end
    end
  end
end
