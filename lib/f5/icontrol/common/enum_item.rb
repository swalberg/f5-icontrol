# This is a helper type to encapsulate iControl
# enumerations in a way which easily gives us
# access to the member as well as the value,
# since the SOAP API and the Savon serializers
# seem to use the string version of the member
# name rather than the value.
#
# Additional iControl enumerations can be generated
# using nimbletest.com/live with '\t' as a column
# separator and the following substitution pattern:
#
# # $2
# $0 = EnumItem.new('$0', '$1')
#
EnumItem = Struct.new(:member, :value) do
  def to_s
    self.member
  end

  def to_i
    self.value
  end
end
