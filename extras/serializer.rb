class Serializer < Struct.new(:object)

  def to_hash(scope = [])
    @hash ||= hash_object(object, scope)
  end

  private

  def hash_object(object, scope = [])
    hash = {}
    hash.merge! object.attributes

    each_association_collection(object) do |association, association_name, item|
      path << object

      if assocation_has_collection?(association) && (scope.empty? || scope.include?(association_name))
        hash[association_name] ||= []
        hash[association_name] << hash_object(item)
      else
        hash[association_name] = hash_object(item)
      end

      path.pop
    end

    hash
  end

  def path
    @path ||= []
  end

  def assocation_has_collection?(association)
    [:has_many, :has_and_belongs_to_many].include? association.macro
  end

  def have_visited_object?(object)
    self.object == object || path.include?(object)
  end

  def each_association_collection(object)
    object.class.reflect_on_all_associations.each do |association|
      association_name = association.name.to_s

      association_collection(object, association_name).each do |item|
        yield(association, association_name, item) unless have_visited_object?(item)
      end
    end
  end

  def association_collection(object, association_name)
    puts object.send(association_name).inspect
    object.send(association_name).to_a
  end

  def visited_objects
    @visited_objects ||= []
  end

end
