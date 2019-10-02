class HummingbirdSurvey::SurveyItemsController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :find_survey_item, only: [:show, :edit, :update, :destroy, :add_show_if]
  before_action :authorize_single, except: :index

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @survey_item.update(survey_item_params)
        format.html { redirect_to edit_survey_path(@survey), notice: 'Survey item was successfully updated.' }
        format.json { render :show, status: :ok, location: @survey_item }
      else
        format.html { render :edit }
        format.json { render json: @survey_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @survey_item.destroy
    respond_to do |format|
      format.html { redirect_to edit_survey_path(@survey), notice: 'Survey item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_show_if
    show_if = ShowIf.create!(showable: @survey_item)

    redirect_to edit_survey_path(@survey), notice: 'Show If was successfully added.'
  end

  private

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def find_survey_item
    @survey_item = SurveyItem.find(params[:id])
    @parent = @survey_item.parent
  end

  def authorize_single
    authorize @survey_item
  end

  def survey_item_params
    params[:survey_item].present? ? params.require(:survey_item).permit(:item_number, :parent_id, :parent_type, :survey_itemable_id, :survey_itemable_type) : {}
  end
end
