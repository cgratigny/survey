require 'securerandom'

# Usage:
# HummingbirdSurvey::SurveyPdfCreatorService.new(survey_link: survey_link).generate

module HummingbirdSurvey
  class SurveyPdfCreatorService
    include ActiveModel::Model

    attr_accessor :survey_link

    def generate

      pdf = Prawn::Document.new

      # loop through and display the responses here
      pdf.text "Add the content here from the survey."

      # pdf.encrypt_document(
      #   user_password: "7fPm>um6KcXDTpLoZo3FfPsW",
      #   owner_password: "7fPm>um6KcXDTpLoZo3FfPsW"
      # )

      pdf.render_file complete_filename
      survey_link.answers_pdf.attach(io: File.open(complete_filename), filename: filename, content_type: 'application/pdf')
      File.delete(complete_filename) if File.exist?(complete_filename)
    end

    def complete_filename
      "#{path}#{filename}"
    end

    def path
      dir = Rails.root.join("tmp/pdf/")
      Dir.mkdir dir unless File.directory?(dir)
      dir
    end

    def filename
      @filename ||= "response-#{survey_link.id}-#{SecureRandom.hex(10)}.pdf"
    end

  end
end
