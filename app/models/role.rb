class Role < ApplicationRecord
  belongs_to :system
  belongs_to :autodenial_workflow, optional: true
  belongs_to :autoapproval_workflow, optional: true
  belongs_to :approval_workflow, optional: true # TODO: make it mandatory? 
  belongs_to :provision_workflow, optional: true # TODO: make it mandatory? 
  has_many :accesses, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :system_id } # this also includes system presence validation
  validates :term, numericality: { greater_than: 0, allow_nil: true }
  validates :approval_workflow, presence: true
  validates :provision_workflow, presence: true
  validate :approval_workflow_properties_correctness, if: -> { approval_workflow.present? }
  validate :provision_workflow_properties_correctness, if: -> { provision_workflow.present? }

  def system_name
    system.name
  end

  def self.ransackable_attributes(auth_object = nil)
    ["name", "is_active"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["system"]
  end

  private

  def approval_workflow_properties_correctness
    case approval_workflow.name
    when "SimpleList"
      validate_approval_workflow_simple_list
    when "SimpleList & PrioritizedList"
      validate_approval_workflow_simple_list_prioritized_list
    else
      errors.add(:approval_workflow, 'is invalid')
    end
  end

  def provision_workflow_properties_correctness
    case provision_workflow.name
    when "LDAPGroupMembership"
      validate_provision_workflow_properties_ldap_group_membership
    else
      errors.add(:provision_workflow, 'is invalid')
    end
  end

  def validate_approval_workflow_simple_list
    validate_approvers_list('list1')
  rescue JSON::ParserError
    errors.add(:approval_workflow_properties, "must be a valid JSON object")
  end

  def validate_approval_workflow_simple_list_prioritized_list
    validate_approvers_list('list1')
    validate_approvers_list('list2')
  rescue JSON::ParserError
    errors.add(:approval_workflow_properties, "must be a valid JSON object")
  end

  def validate_approvers_list(list_name)
    approvers = approval_workflow_properties[list_name]
    unless approvers_valid?(approvers)
      errors.add(:approval_workflow_properties, "contain invalid approvers list")
    end
  end
  
  def approvers_valid?(approvers)
    return false unless approvers.present? && approvers.is_a?(Array) && approvers.any?
    approvers.any? { |user_id| valid_user?(user_id) }
  end

  def valid_user?(user_id)
    user_id.present? && User.exists?(user_id) && User.find(user_id).is_active?
  end

  def validate_provision_workflow_properties_ldap_group_membership
    unless provision_workflow_properties['list1'].present?
      errors.add(:provision_workflow_properties, "can't be blank")
      return
    end
    ldap_groups = provision_workflow_properties['list1']
    unless ldap_groups.is_a?(Array) && ldap_groups.any? && ldap_groups_exist?(ldap_groups)
      errors.add(:provision_workflow_properties, "must contain only valid LDAP entries")
      return
    end
    unless ldap_groups_unique?(ldap_groups)
      errors.add(:provision_workflow_properties, "must contain LDAP entries that are unique among all other access roles")
    end
  rescue JSON::ParserError
    errors.add(:provision_workflow_properties, "must be a valid JSON object")
  end

  def ldap_groups_exist?(ldap_groups)
    ldap_groups.each do |group|
      if group.downcase.include?(Rails.application.config.ldap_base&.downcase)
        host     = Rails.application.config.ldap_host
        port     = Rails.application.config.ldap_port
        username = Rails.application.config.ldap_username
        password = Rails.application.config.ldap_password
        base     = Rails.application.config.ldap_base
        filter   = Net::LDAP::Filter.eq('DistinguishedName', group)
        attrs    = %w[dn]
      elsif group.downcase.include?(ENV.fetch("OL_BASE")&.downcase)
        host     = ENV.fetch("OL_HOSTNAME")
        port     = Rails.application.config.ldap_port
        username = ENV.fetch("OL_USERNAME")
        password = ENV.fetch("OL_PASSWORD")
        base     = group
        filter   = "(objectClass=posixGroup)"
        attrs    = %w[cn]
      else
        return false
      end

      ldap = LdapService.new(host, port, base)
      if ldap.authenticate(username, password)
        search_result = ldap.search(base, filter, attrs)
        return false unless search_result.present?
      end
    end
  end

  def ldap_groups_unique?(ldap_groups)
    ldap_groups = ldap_groups.map(&:downcase)
    provision_workflow = ProvisionWorkflow.where(name: "LDAPGroupMembership" )
    roles = Role.where(provision_workflow: provision_workflow).where.not(id: self.id)
    existing_values = roles.map do |role|
      list1_values = role.provision_workflow_properties.dig('list1')
      list1_values&.map(&:downcase)
    end.compact.flatten
    duplicates = ldap_groups.select { |value| existing_values.include?(value) }
    duplicates.empty?
  end

end