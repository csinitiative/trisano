# The Record Number format for an event.
# 
# YYYYTNNNNN
#
# YYYY - Year
# T - will be a 0 -5 for all NEDSS data entry for 2008
#  9 - NETSS entered data that is migrated to NEDSS
#  8 - TIMS entered data that is migrated to NEDSS
#  7 - STD-MIS entered data that is migrated to NEDSS
#  6 - HARS entered data that is migrated to NEDSS
#  NNNNN - 00001 - 99999 1 greater than previously entered record for NEDSS entered data or
#  NETSS, TIMS, STD-MIS or HARS record number
#
# This would keep the existing systems (NETSS, TIMS, STD-MIS, or HARS) record numbers for NEDSS backward compatibility.
#
# EXAMPLES:
# 2007900032 - 32nd NETSS record entered in 2007; NETSS number 0032
#
# 2008000005 - 5th NEDSS record entered in 2008; record entered directly into NEDSS
# 2008900005 - 5th NETSS record entered in 2008; NETSS number 0005
#
class RecordNumber    

  def initialize(*args)    
    
    case args.size
        
    when 1
      raise ArgumentError, "RecordNumber: Expected Integer" if !args[0].is_a?(Integer)
      @count = args[0]
      t = Time.now
      @year = Date.new(t.year, t.month, t.day)
      @system = :nedss
    when 2
      raise ArgumentError, "RecordNumber: Expected Date" if !args[0].is_a?(Date)
      raise ArgumentError, "RecordNumber: Expected Integer" if !args[1].is_a?(Integer)
      @year = args[0]
      @count = args[1]
      @system = :nedss
    when 3
      raise ArgumentError, "RecordNumber: Expected Date" if !args[0].is_a?(Date)
      raise ArgumentError, "RecordNumber: Expected Integer" if !args[1].is_a?(Integer)
      raise ArgumentError, "RecordNumber: Expected Symbol" if !args[2].is_a?(Symbol)
      @year = args[0]
      @count = args[1]      
      @system = args[2]
    else
      raise ArgumentError, "RecordNumber initialize takes 1, 2, or 3 arguments."
    end
    
  end
  
  def value    
    val = @year.year.to_s + system_number
    val +=  converted_count    
  end

  private 
  
  def system_number    
    case @system
    when :netss
      "9"
    when :tims
      "8"
    when :stdmis
      "7"
    when :hars
      "6"
    when :nedss
      "5"
    else
      raise "Unknown @system: #{@system}"
    end
  end
  
  def converted_count
    @count.to_s.rjust(5, "0")
  end
end
