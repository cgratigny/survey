class CreateSurveyTables < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :surveys do |t|
      t.references :surveyable, polymorphic: true
      t.string :display_name
      t.jsonb :data, default: {}

      t.timestamps
    end

    create_table :survey_links do |t|
      t.references :survey
      t.references :surveyed, polymorphic: true
      t.jsonb :answers_data, default: {}
      t.jsonb :request_data, default: {}

      t.timestamps
    end

    create_table :survey_pages do |t|
      t.references :survey, foreign_key: true
      t.string :title
      t.integer :page_number

      t.timestamps
    end

    create_table :survey_items do |t|
      t.integer :item_number
      t.references :parent, polymorphic: true
      t.references :survey_itemable, polymorphic: true, index: {name: :index_survey_item_on_itemable}

      t.timestamps
    end

    create_table :survey_questions do |t|
      t.text :label
      t.string :question_type
      t.boolean :required, default: true
      t.jsonb :data, default: {}

      t.timestamps
    end

    create_table :survey_notes do |t|
      t.text :content

      t.timestamps
    end

    create_table :survey_sections do |t|
      t.string :title

      t.timestamps
    end
  end
end
