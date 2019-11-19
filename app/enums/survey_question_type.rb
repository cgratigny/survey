class SurveyQuestionType < ClassyEnum::Base
  def requires_answer_list?
    false
  end

  def response_partial
    :default
  end

  def fields
    []
  end

  def all_fields
    SurveyQuestionType.all.map{|type| type.fields}.flatten.uniq
  end

  def checkbox_type?
    false
  end
end

class SurveyQuestionType::Encrypted < SurveyQuestionType
  def response_partial
    :encrypted
  end
end

class SurveyQuestionType::Signature < SurveyQuestionType
  def response_partial
    :signature
  end
end

class SurveyQuestionType::TextField < SurveyQuestionType
  def text
    "Short Answer"
  end
end

class SurveyQuestionType::Review < SurveyQuestionType
end

class SurveyQuestionType::Agreement < SurveyQuestionType
  def checkbox_type?
    true
  end

  def fields
    [:agree_text]
  end

  def response_partial
    :agreement
  end
end

class SurveyQuestionType::TextArea < SurveyQuestionType
  def text
    "Paragraph Answer"
  end

  def response_partial
    :text_area
  end
end

class SurveyQuestionType::RadioButtons < SurveyQuestionType
  def requires_answer_list?
    true
  end
end

class SurveyQuestionType::Checkbox < SurveyQuestionType
  def checkbox_type?
    true
  end

  def requires_answer_list?
    true
  end

  def response_partial
    :checkbox
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

  def response_partial
    :multi_select
  end
end

class SurveyQuestionType::CountrySelect < SurveyQuestionType
end

class SurveyQuestionType::RegionSelect < SurveyQuestionType
end
