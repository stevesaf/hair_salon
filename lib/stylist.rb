class Stylist

attr_reader(:name, :id) #We place these here so that we do not need to define the variables below initialize

define_method(:initialize) do |attributes|
  @name = attributes.fetch(:name)
  @id = attributes[:id] #We place id as such because it will be automatically assigned from DB; we are not fetching from input data.
end

define_singleton_method(:all) do
  returned_stylists = DB.exec("SELECT * FROM stylist;") #Here, we are selecting all of the stylists from the stylist table in the DB. We loop through each of them and pull out their name and id, create a new Stylist object and push it into an array.
  stylists = []
  returned_stylists.each() do |stylist|
    name = stylist.fetch("name")
    id = stylist.fetch("id").to_i() #we need to put the id to an integer as the information that comes out of the DB is in a string.
    stylists.push(Stylist.new({:name => name, :id => id})) #Setting the key => value pair for the hash that will contain the information we need to draw
  end
  stylists
end

define_method(:==) do |another_stylist|
  self.name().==(another_stylist.name()).&(self.id().==(another_stylist.id())) #basically saying if the input name and id is equal to another matching pair, they are the same.
end

define_method(:save) do #1. Everything pulled from DB is a string, so must be converted to int.
  result = DB.exec("INSERT INTO stylist (name) VALUES ('#{@name}') RETURNING id;") #2. We can insert with a name and have the DB assign/return a serial id.
  @id = result.first().fetch("id").to_i() #3. pg gem returns info in an array, so we can get an id by using the first() method to take out of array and use fetch() to select id.
end

define_singleton_method(:find) do |id|
        found_stylist = nil
        Stylist.all().each() do |stylist|
            if stylist.id().==(id)
                found_stylist = stylist
            end
        end
        found_stylist
    end

define_method(:clients) do
  stylist_clients = []
  clients = DB.exec("SELECT * FROM client WHERE stylist_id = #{self.id()};")
  clients.each() do |client|
    name = client.fetch("name")
    stylist_id = client.fetch("stylist_id").to_i()
    stylist_clients.push(Client.new({:name => name, :stylist_id => stylist_id}))
  end
  stylist_clients
end

define_method(:delete) do #We need to make sure it deletes the stylist and any clients associated with them.
    DB.exec("DELETE FROM stylist WHERE id = #{self.id()};")
    DB.exec("DELETE FROM client WHERE stylist_id = #{self.id()};")
end

define_method(:update) do |attributes|
  @name = attributes.fetch(:name)
  @id = self.id()
  DB.exec("UPDATE stylist SET name = '#{name}' WHERE id = #{id};")
end



end
