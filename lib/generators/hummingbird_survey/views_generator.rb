require 'rails/generators'

module HummingbirdSurvey
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      def copy_views
        directory 'app/views/common/survey', 'app/views/common/survey'
      end
    end
  end
end
