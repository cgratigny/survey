class HummingbirdSurvey::SurveysController < HummingbirdSurvey::BaseController
  before_action :build_collection, only: :index
  before_action :authorize_multiple, only: :index

  before_action :build_survey, only: [:new, :create]
  before_action :find_survey, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def show
  end

  def new
  end

  def create
    respond_to do |format|
      if @survey.save!
        format.html { redirect_to DynamicPath.new.surveyable_path(@survey), notice: 'Survey was successfully created.' }
        format.json { render :show, status: :created, location: @survey }
      else
        format.html { render :new }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @survey.update!(survey_params)
        format.html { redirect_to DynamicPath.new.surveyable_path(@survey), notice: 'Survey was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey }
      else
        format.html { render :edit }
        format.json { render json: @survey.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey.destroy
    respond_to do |format|
      format.html { redirect_to DynamicPath.new.surveyable_path(@survey), notice: 'Survey was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def build_collection
    @surveys = Survey.all
  end

  def build_survey
    @survey = Survey.new(survey_params)
  end

  def find_survey
    @survey = Survey.find(params[:id])
  end

  def authorize_multiple
    authorize @surveys
  end

  def authorize_single
    authorize @survey
  end

  def survey_params
    params[:survey].present? ? params.require(:survey).permit(:surveyable_id, :surveyable_type, :display_name) : {}
  end
end
