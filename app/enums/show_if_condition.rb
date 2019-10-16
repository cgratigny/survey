class ShowIfCondition < ClassyEnum::Base
  def resolve(target_value, given_value)
    false
  end
end

class ShowIfCondition::Equal < ShowIfCondition
  def resolve(target_value, given_value)
    given_value.to_s == target_value.to_s
  end
end

class ShowIfCondition::NotEqual < ShowIfCondition
  def resolve(target_value, given_value)
    given_value.to_s != target_value.to_s
  end
end
