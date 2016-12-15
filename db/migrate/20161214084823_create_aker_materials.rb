class CreateAkerMaterials < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :aker_materials, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.timestamps
    end
  end
end
