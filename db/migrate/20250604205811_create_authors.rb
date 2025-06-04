# db/migrate/YYYYMMDDHHMMSS_create_authors.rb
class CreateAuthors < ActiveRecord::Migration[7.1] # Ou a versão do Rails que você está usando, ex: 7.1
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.string :type, null: false # Para STI (PersonAuthor, InstitutionAuthor)

      # Campos específicos para PersonAuthor (podem ser nulos na tabela base)
      t.date :date_of_birth

      # Campos específicos para InstitutionAuthor (podem ser nulos na tabela base)
      t.string :city

      t.timestamps
    end
    add_index :authors, :type
    add_index :authors, :name # Adicionar um índice ao nome pode ser útil para buscas
  end
end