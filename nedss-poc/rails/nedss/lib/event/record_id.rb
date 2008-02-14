# 
# The Record ID format for an entity.
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
class RecordId
  def initialize(*args)
    
  end
end
