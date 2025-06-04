# db/migrate/YYYYMMDDHHMMSS_create_materials.rb
class CreateMaterials < ActiveRecord::Migration[7.1] # Ou a versão do Rails que você está usando, ex: 7.1
  def change
    create_table :materials do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false
      t.string :type, null: false # Para STI (Book, Article, Video)

      t.references :user, null: false, foreign_key: true # Criador (usuário logado)
      t.references :author, null: false, foreign_key: true

      # Campos específicos para Book (podem ser nulos na tabela base)
      t.string :isbn
      t.integer :number_of_pages

      # Campos específicos para Article (podem ser nulos na tabela base)
      t.string :doi

      # Campos específicos para Video (podem ser nulos na tabela base)
      t.integer :duration_minutes

      t.timestamps
    end

    add_index :materials, :type
    add_index :materials, :status
    add_index :materials, :title # Adicionar um índice ao título pode ser útil para buscas
    add_index :materials, :isbn, unique: true   # ISBN deve ser único
    add_index :materials, :doi, unique: true    # DOI deve ser único
    # Considere outros índices conforme necessário para otimizar consultas
  end
end