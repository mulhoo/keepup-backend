class AddSportTemplatesAndTeamLevels < ActiveRecord::Migration[8.0]
  def change
    # District-managed sport catalog
    create_table :sport_templates do |t|
      t.references :district,       null: false, foreign_key: true
      t.string  :name,              null: false
      t.integer :athletic_season,   null: false, default: 0  # fall/winter/spring/year_round
      t.integer :gender_config,     null: false, default: 0  # 0=separate, 1=combined
      t.boolean :active,            null: false, default: true
      t.timestamps
    end
    add_index :sport_templates, [ :district_id, :name ], unique: true

    # AD-configurable levels per school sport (Varsity, JV, C Team, etc.)
    create_table :team_levels do |t|
      t.references :sport,          null: false, foreign_key: true
      t.string  :name,              null: false
      t.integer :display_order,     null: false, default: 0
      t.boolean :active,            null: false, default: true
      t.timestamps
    end
    add_index :team_levels, [ :sport_id, :name ], unique: true

    # Sport: swap name+athletic_season for template reference + gender
    add_reference :sports, :sport_template, foreign_key: true, null: true
    add_column    :sports, :gender, :integer, null: false, default: 1  # 0=boys, 1=girls, 2=coed
    remove_column :sports, :name,            :string
    remove_column :sports, :athletic_season, :integer
    add_index :sports, [ :sport_template_id, :school_id, :gender ], unique: true

    # Season: add team_level, update unique constraint
    add_reference :seasons, :team_level, foreign_key: true, null: true
    remove_index  :seasons, [ :sport_id, :school_year ]
    add_index     :seasons, [ :team_level_id, :school_year ], unique: true
  end
end
