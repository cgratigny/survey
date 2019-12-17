class SurveyType < ClassyEnum::Base
end

class SurveyType::Default < SurveyType
end

class SurveyType::Quiz < SurveyType
end

class SurveyType::AssignmentSurvey < SurveyType
end
