class HummingbirdSurvey::SurveyResponseViewsController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :build_survey_response_view, only: [:new, :create]
  before_action :find_survey_response_view, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def show
  end

  def edit
  end

  def new

  end

  def create
    respond_to do |format|
      if @survey_response_view.save
        format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey view was successfully created.' }
        format.json { render :show, status: :created, location: @survey }
      else
        format.html { render :new }
        format.json { render json: @survey_response_view.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @survey_response_view.update(survey_response_view_params)
        format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey view was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_response_view }
      else
        format.html { render :edit }
        format.json { render json: @survey_response_view.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_response_view.destroy
    respond_to do |format|
      format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Survey view was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def build_survey_response_view
    @survey_response_view = SurveyResponseView.new(survey_response_view_params)
    @survey_response_view.survey = @survey
  end

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def find_survey_response_view
    @survey_response_view = SurveyResponseView.find(params[:id])
  end

  def authorize_single
    authorize @survey_response_view
  end

  def survey_response_view_params
    params[:survey_response_view].present? ? params.require(:survey_response_view).permit(:name, :internal_description, :survey_id, data: {} ) : {}
  end
end
