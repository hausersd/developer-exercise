class Array

  def where(condition)
    result = []

    if condition.nil? #if there are no conditions, return everything
      return self
    end

    key = condition.keys[0] #pull out the first condition
    value = condition.values[0]
    condition.delete(key) #remove the first condition from the hash

    self.each do |hsh|
      begin
        if value.is_a?(Regexp)#check if the condition is a regular expression
          result << hsh if hsh.fetch(key) =~ value
        else
          result << hsh if hsh.fetch(key) == value
        end
      rescue KeyError #KeyError is raised if key is not in the calling array
        puts 'Invalid condition; no such key: #{key}'
      end
    end

    if condition.length > 0 #check if there are more conditions to check
      result = result.where(condition) #if there are, recursively check them on the result array
    end

    return result
  end
end

@boris   = {:name => 'Boris The Blade', :quote => "Heavy is good. Heavy is reliable. If it doesn't work you can always hit them.", :title => 'Snatch', :rank => 4}
@charles = {:name => 'Charles De Mar', :quote => 'Go that way, really fast. If something gets in your way, turn.', :title => 'Better Off Dead', :rank => 3}
@wolf    = {:name => 'The Wolf', :quote => 'I think fast, I talk fast and I need you guys to act fast if you wanna get out of this', :title => 'Pulp Fiction', :rank => 4}
@glen    = {:name => 'Glengarry Glen Ross', :quote => "Put. That coffee. Down. Coffee is for closers only.",  :title => "Blake", :rank => 5}

@fixtures = [@boris, @charles, @wolf, @glen]

puts @fixtures.where(:foo => /if/i)
