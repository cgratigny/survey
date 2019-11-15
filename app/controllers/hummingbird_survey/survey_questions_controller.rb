class HummingbirdSurvey::SurveyQuestionsController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :find_survey_question, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @survey_question.update(survey_question_params)
        format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey question was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_question }
      else
        format.html { render :edit }
        format.json { render json: @survey_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_question.destroy
    respond_to do |format|
      format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def find_survey_question
    @survey_question = SurveyQuestion.find(params[:id])
    @survey_item = @survey_question.survey_item
  end

  def authorize_single
    authorize @survey_question
  end

  def survey_question_params
    if params[:survey_question].present? && params[:survey_question][:answer_list].present?
      str = params[:survey_question][:answer_list]
      result = str.split(", ")
      params[:survey_question][:answer_list] = result
    end

    params[:survey_question].present? ? params.require(:survey_question).permit(:label, :required, :question_type, :linked_field_name, :country_question_id, *SurveyQuestionType.new.all_fields, answer_list: []) : {}
  end
end
