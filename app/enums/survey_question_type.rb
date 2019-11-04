class SurveyQuestionType < ClassyEnum::Base
  def requires_answer_list?
    false
  end
end

class SurveyQuestionType::Encrypted < SurveyQuestionType
end

class SurveyQuestionType::Signature < SurveyQuestionType
end

class SurveyQuestionType::TextField < SurveyQuestionType
  def text
    "Short Answer"
  end
end

class SurveyQuestionType::TextArea < SurveyQuestionType
  def text
    "Paragraph Answer"
  end
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

class SurveyQuestionType::MultiSelect < SurveyQuestionType
  def requires_answer_list?
    true
  end
end

class SurveyQuestionType::CountrySelect < SurveyQuestionType
end

class SurveyQuestionType::RegionSelect < SurveyQuestionType
end
