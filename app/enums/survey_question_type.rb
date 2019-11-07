class SurveyQuestionType < ClassyEnum::Base
  def requires_answer_list?
    false
  end

  def fields
    []
  end

  def all_fields
    SurveyQuestionType.all.map{|type| type.fields}.flatten.uniq
  end
end

class SurveyQuestionType::Encrypted < SurveyQuestionType
end

class SurveyQuestionType::Signature < SurveyQuestionType
end

class SurveyQuestionType::TextField < SurveyQuestionType
end

class SurveyQuestionType::Agreement < SurveyQuestionType
  def fields
    [:agree_text]
  end
end

class SurveyQuestionType::TextArea < SurveyQuestionType
end

class SurveyQuestionType::RadioButtons < SurveyQuestionType
  def requires_answer_list?
    true
  end
end

class SurveyQuestionType::Checkbox < SurveyQuestionType
  def requires_answer_list?
    true
  end
end

class SurveyQuestionType::Select < SurveyQuestionType
  def requires_answer_list?
    true
  end
end

class SurveyQuestionType::CountrySelect < SurveyQuestionType
end

class SurveyQuestionType::RegionSelect < SurveyQuestionType
end
