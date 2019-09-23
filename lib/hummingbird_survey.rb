require 'rails'

require 'hummingbird_survey/models/itemable.rb'
require 'hummingbird_survey/models/notable.rb'
require 'hummingbird_survey/models/pagable.rb'
require 'hummingbird_survey/models/sectionable.rb'
require 'hummingbird_survey/models/surveyable.rb'
require 'hummingbird_survey/models/questionable.rb'
require 'hummingbird_survey/railtie.rb'

module HummingbirdSurvey
  def self.hi
    puts "Hello world!"
  end
end
