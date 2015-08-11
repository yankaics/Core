class UserDecorator < Draper::Decorator
  delegate_all
  decorates_association :primary_identity, with: UserIdentityDecorator
  decorates_association :identities, with: UserIdentityDecorator

  def identity_description
    if primary_identity.blank?
      if Settings.enable_user_unconfirmed_identity && unconfirmed_organization
        "(未驗證) #{unconfirmed_organization_short_name} #{unconfirmed_department_short_name}"
      else
        return '未知'
      end
    end
    "#{organization_name} #{department_name} #{UserIdentity.human_enum_value(:identity, identity)}"
  end

  def unconfirmed_identity_description
    return '沒有未經驗證的身份' unless unconfirmed_organization
    "#{unconfirmed_organization_short_name} #{unconfirmed_department_short_name} (#{unconfirmed_started_year})"
  end

  def identity_short_description
    if primary_identity.blank?
      if Settings.enable_user_unconfirmed_identity && unconfirmed_organization
        "(未驗證) #{unconfirmed_organization_short_name} #{unconfirmed_department_short_name}"
      else
        return '未知'
      end
    end
    "#{organization_short_name} #{department_short_name} #{UserIdentity.human_enum_value(:identity, identity)}"
  end
end
