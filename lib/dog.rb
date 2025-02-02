require 'pry'

class Dog
   attr_accessor :name,:breed,:id

   def initialize(name:,breed:,id:nil)
      @name=name
      @breed=breed
      @id=id
   end

   def self.create_table
      sql=<<-SQL
         CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
         );
      SQL
      DB[:conn].execute(sql)
   end

   def self.drop_table
      DB[:conn].execute("DROP TABLE dogs;")
   end

   def self.new_from_db(array)
      new_d=Dog.new(name:array[1],breed:array[2],id:array[0])
      new_d
   end

   def self.find_by_name(name)
      sql=<<-SQL
         SELECT * FROM dogs
         WHERE name=?
         LIMIT 1
      SQL
      DB[:conn].execute(sql,name).map do |row|
         self.new_from_db(row)
      end.first
   end

   def self.find_by_id(int)
      sql=<<-SQL
         SELECT * FROM dogs
         WHERE id=?
         LIMIT 1
      SQL
      DB[:conn].execute(sql,int).map do |row|
         self.new_from_db(row)
      end.first
   end

   def self.find_or_create_by(name:,breed:)
      dog=DB[:conn].execute("SELECT * FROM dogs WHERE name=? AND breed=?", name, breed)
      if !dog.empty?
         dog_info=dog[0]
         dog=Dog.new(name:dog_info[1],breed:dog_info[2],id:dog_info[0])
      else
         self.create(name:name,breed:breed)
      end
   end

   def update
      sql=<<-SQL
         UPDATE dogs
         SET name=?, breed=?
         WHERE id=?
      SQL
      DB[:conn].execute(sql,self.name,self.breed,self.id)
   end

   def save
      sql=<<-SQL
         INSERT INTO dogs (name,breed)
         VALUES (?,?)
      SQL
      DB[:conn].execute(sql,self.name,self.breed)
      @id=DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
      self
   end


   def self.create(name:,breed:,id:nil)
      n_dog=self.new(name:name,breed:breed,id:id)
      n_dog.save
      n_dog
   end



end