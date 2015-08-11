class UserIdentityDecorator < Draper::Decorator
  delegate_all

  def description
    "#{organization_name} #{UserIdentity.human_enum_value(:identity, identity)}"
  end
end
