module CustomMatchers  
  class AcceptNestedAttributes  
    #do any setup required - at the very least, set some instance variables.  
    def initialize(expected)
      @expected = expected  
    end  
  
    def matches?(target)  
      @target = target
      @target.respond_to?("#{@expected}_attributes=")
    end  
  
    def failure_message  
      "expected #{@target.inpsect} to accept nested attributes for #{@expected}"  
    end  
  
    def negative_failure_message  
      "expected #{@target.inpsect} to not accept nested attributes for #{@expected}"  
    end  
  
    #displayed in the spec description if the user doesn't provide one (ie if they just write 'it do' for the spec header)  
    def description  
      "accept nested attributes for #{@expected}"  
    end  
  
    # Returns string representation of the object being tested  
    def to_s(value)  
      "#{@expected.inspect}"  
    end  
  end  
  
  # the matcher method that the user calls in their specs  
  def accept_nested_attributes_for(expected)
    AcceptNestedAttributes.new(expected)
  end  
end  
