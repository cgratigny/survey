class HummingbirdSurvey::ShowIfsController < HummingbirdSurvey::BaseController
  before_action :find_survey

  before_action :find_show_if, only: [:show, :edit, :update, :destroy]
  before_action :authorize_single, except: :index

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @show_if.update(show_if_params)
        format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Show if was successfully updated.' }
        format.json { render :show, status: :ok, location: @show_if }
      else
        format.html { render :edit }
        format.json { render json: @show_if.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @show_if.destroy
    respond_to do |format|
      format.html { redirect_to edit_staff_survey_path(@survey), notice: 'Show if was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def find_survey
    @survey = Survey.find(params[:survey_id])
  end

  def find_show_if
    @show_if = ShowIf.find(params[:id])
  end

  def authorize_multiple
    authorize @show_ifs
  end

  def authorize_single
    authorize @show_if
  end

  def show_if_params
    params[:show_if].present? ? params.require(:show_if).permit(:survey_question_id, :condition, :target_value) : {}
  end
end
